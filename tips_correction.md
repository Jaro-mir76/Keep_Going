# TipKit Bug Analysis: MarkAsDoneTip Appearing While EditGoalView Is Visible

## Current Implementation Analysis

The app uses TipKit for onboarding users through goal creation and management. The flow is:
1. User adds first goal (AddGoalTip)
2. User fills in goal details in EditGoalView (GoalNameTip, GoalMotivationTip, etc.)
3. User saves the goal
4. User returns to MainView where EditGoalTip appears
5. User swipes right and edits a goal
6. **BUG: MarkAsDoneTip appears while EditGoalView is still visible**

## Root Cause

The bug stems from line 38-40 in `MainView.swift`:

```swift
Button {
    mainEngine.selectedGoal = goal
    showEditing = true
    if !OnboardingProgress.hasEditedGoal {
        OnboardingProgress.hasEditedGoal = true  // <-- Sets the flag immediately
    }
} label: {
    Label("Edit", systemImage: "pencil")
        .labelStyle(.iconOnly)
}
```

The `hasEditedGoal` parameter is set to `true` **immediately** when the edit button is tapped, before EditGoalView is even presented. This triggers the MarkAsDoneTip rules to evaluate as eligible right away.

MarkAsDoneTip rules in `MarkAsDoneTip.swift` (lines 24-29):
```swift
var rules: [Rule] {
    [
        #Rule(OnboardingProgress.$hasMarkedGoalDone) { $0 == false },
        #Rule(OnboardingProgress.$hasEditedGoal) { $0 == true }  // <-- Already true!
    ]
}
```

MarkAsDoneTip is displayed in `GoalCardView.swift` (lines 90 and 100):
```swift
.popoverTip(markAsDoneTip, arrowEdge: .trailing)
```

Since GoalCardView instances remain visible in MainView's List even when the EditGoalView sheet is presented (sheets don't remove the underlying view from the hierarchy), and the rules now evaluate to true, TipKit immediately displays the tip on GoalCardView.

## The Problem

1. User taps swipe-to-edit button
2. `hasEditedGoal` is set to true immediately (wrong timing)
3. EditGoalView sheet presents
4. GoalCardView (still in view hierarchy behind sheet) checks MarkAsDoneTip rules
5. Rules pass (hasEditedGoal == true, hasMarkedGoalDone == false)
6. Tip displays while EditGoalView is still visible on screen

## Proposed Solution

Move the `hasEditedGoal` flag update to **after** the EditGoalView is dismissed. This ensures the tip only appears when the user is back on MainView where they can actually mark goals as done.

### Code Changes

**File: `/Keep_Going/Keep_Going/Views/MainView.swift`**

**OLD CODE (lines 34-45):**
```swift
.swipeActions(edge: .leading, allowsFullSwipe: false) {
    Button {
        mainEngine.selectedGoal = goal
        showEditing = true
        if !OnboardingProgress.hasEditedGoal {
            OnboardingProgress.hasEditedGoal = true
        }
    } label: {
        Label("Edit", systemImage: "pencil")
            .labelStyle(.iconOnly)
    }
}
```

**NEW CODE:**
```swift
.swipeActions(edge: .leading, allowsFullSwipe: false) {
    Button {
        mainEngine.selectedGoal = goal
        showEditing = true
        // Remove immediate flag setting - moved to sheet dismiss handler
    } label: {
        Label("Edit", systemImage: "pencil")
            .labelStyle(.iconOnly)
    }
}
```

**OLD CODE (line 58):**
```swift
.sheet(isPresented: $showEditing) {
    EditGoalView(goal: mainEngine.selectedGoal)
}
```

**NEW CODE:**
```swift
.sheet(isPresented: $showEditing, onDismiss: {
    // Set flag after sheet is fully dismissed
    if mainEngine.selectedGoal != nil && !OnboardingProgress.hasEditedGoal {
        OnboardingProgress.hasEditedGoal = true
    }
}) {
    EditGoalView(goal: mainEngine.selectedGoal)
}
```

### Why This Works

1. User swipes to edit → showEditing = true → sheet presents
2. User interacts with EditGoalView
3. User taps Save or Cancel → dismiss() is called
4. **Sheet dismisses completely**
5. **onDismiss closure executes** → hasEditedGoal = true
6. User is now back on MainView
7. MarkAsDoneTip rules evaluate → eligible to show
8. Tip appears on GoalCardView where user can actually see the long-press action

## Additional Recommendations

### 1. Consider Delayed Tip Presentation

Add a small delay before the tip appears to avoid jarring transitions:

```swift
.sheet(isPresented: $showEditing, onDismiss: {
    if mainEngine.selectedGoal != nil && !OnboardingProgress.hasEditedGoal {
        // Delay to let sheet animation complete and user reorient
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            OnboardingProgress.hasEditedGoal = true
        }
    }
}) {
    EditGoalView(goal: mainEngine.selectedGoal)
}
```

### 2. Verify Edit Actually Occurred

The current implementation sets `hasEditedGoal = true` even if the user taps Cancel. Consider only setting it when Save is tapped:

**In EditGoalView.swift**, modify the save() function (lines 284-291):

```swift
if goal == nil {
    OnboardingProgress.hasAddedFirstGoal = true
} else {
    // Only mark as edited when actually saving changes to an existing goal
    OnboardingProgress.hasEditedGoal = true
}
```

This approach is semantically more accurate: the user has "edited a goal" when they've actually committed changes, not just opened the edit view.

### 3. Review MarkAsDoneTip Placement

MarkAsDoneTip appears on every eligible GoalCardView (lines 90 and 100 in GoalCardView.swift). If there are multiple goals, the tip could appear on all of them simultaneously. Consider showing it only on the first eligible goal to avoid visual clutter.

### 4. Parameter Naming Inconsistency

`OnboardingProgress.markAsDoneTip` (line 34 in OnboardingProgress.swift) should be named `hasSeenMarkAsDoneTip` or similar to match the naming convention of other parameters. Currently it's not descriptive enough.

## Summary

The bug is a timing issue: the onboarding parameter is set before the modal dismisses, causing the tip to appear while the modal is still visible. Move the parameter update to the sheet's onDismiss handler to ensure the tip only appears when the user can actually perform the action being taught.
