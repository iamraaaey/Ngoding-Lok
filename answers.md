# CodeQuest Curriculum: Solved Level Solutions

This document contains the working solutions for all Python and Java track modules. Developers can use these solutions to test individual levels or verify the compiler's output.

---

## Python Track Solutions

### Module 1: Sequential Steps
- **Objective**: Move the player to (3,3) on a 5x5 grid from (0,0).
- **Solution**:
  ```python
  move.right();
  move.right();
  move.right();
  move.down();
  move.down();
  move.down();
  ```

### Module 2: Intro to SQL
- **Objective**: Find the password for the 'admin' user.
- **Solution**:
  ```sql
  SELECT password FROM users WHERE role = 'admin';
  -- OR
  SELECT password FROM users WHERE username = 'admin';
  ```

### Module 3: Aerospace Logic
- **Objective**: Complete preflight, start engine, and reach 100km altitude.
- **Solution**:
  ```python
  sys.preflight();
  engine.start();
  throttle(500);
  ```

### Module 4: Backtrack Basics
- **Objective**: Start at bottom-right (4,4), go to top-left (0,0). (4 left, 4 up).
- **Solution**:
  ```python
  move.left();
  move.left();
  move.left();
  move.left();
  move.up();
  move.up();
  move.up();
  move.up();
  ```

### Module 5: The Long Trek
- **Objective**: Start at (0,0), navigate to (6,6) on a 7x7 grid. (6 right, 6 down).
- **Solution**:
  ```python
  move.right();
  move.right();
  move.right();
  move.right();
  move.right();
  move.right();
  move.down();
  move.down();
  move.down();
  move.down();
  move.down();
  move.down();
  ```

### Module 6: Filtering 101
- **Objective**: List student names where the grade is 'A'.
- **Solution**:
  ```sql
  SELECT name FROM students WHERE grade = 'A';
  ```

### Module 7: High Orbit
- **Objective**: Complete preflight, start engine, and reach 250km altitude.
- **Solution**:
  ```python
  sys.preflight();
  engine.start();
  throttle(1250);
  ```

### Module 8: Center Escape
- **Objective**: Start mid-grid at (2,2) and escape to top-right at (5,0). (3 right, 2 up).
- **Solution**:
  ```python
  move.right();
  move.right();
  move.right();
  move.up();
  move.up();
  ```

### Module 9: Sorting Secrets
- **Objective**: Rank Alice's tournament scores board from highest to lowest.
- **Solution**:
  ```sql
  SELECT * FROM scores ORDER BY points DESC;
  ```

### Module 10: Gravity Well
- **Objective**: Escape the gravity well by reaching 400km altitude.
- **Solution**:
  ```python
  sys.preflight();
  engine.start();
  throttle(2000);
  ```

### Module 11: The Grand Maze
- **Objective**: Start at top-right (7,0) and reach bottom-left (0,7). (7 left, 7 down).
- **Solution**:
  ```python
  move.left();
  move.left();
  move.left();
  move.left();
  move.left();
  move.left();
  move.left();
  move.down();
  move.down();
  move.down();
  move.down();
  move.down();
  move.down();
  move.down();
  ```

### Module 12: Counting Heads
- **Objective**: Aggregate the player count.
- **Solution**:
  ```sql
  SELECT COUNT(*) FROM players;
  ```

### Module 13: Escape Velocity
- **Objective**: Graduation flight: reach 600km altitude.
- **Solution**:
  ```python
  sys.preflight();
  engine.start();
  throttle(3000);
  ```

---

## Java Track Solutions

### Java Level 1: Variables & Method Calls
- **Objective**: Move the player to (3,3) on a 5x5 grid from (0,0).
- **Solution**:
  ```java
  move.right();
  move.right();
  move.right();
  move.down();
  move.down();
  move.down();
  ```

### Java Level 2: Control Flow Filtering
- **Objective**: List student names where the grade is 'A'.
- **Solution**:
  ```sql
  SELECT name FROM students WHERE grade = 'A';
  ```

### Java Level 3: Space Object Control
- **Objective**: Initiate spacecraft preflight and start engines to reach 150km altitude.
- **Solution**:
  ```java
  sys.preflight();
  engine.start();
  throttle(750);
  ```
