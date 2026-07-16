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

---

## Cybersecurity Track Solutions

All cybersecurity rooms are deterministic browser simulations. No command,
login, inbox, cipher, or file operation touches a real system.

### Room 1: Warmup Web Server

1. `21,80`
2. `FTP`
3. `HTTP`
4. `FLAG{an0n_ftp_1s_r1sky}`

Terminal path: `nmap target.thm` → `ftp target.thm` → `ls` → `cat flag.txt`.

### Room 2: Training Portal Login

1. `Structured Query Language` (also accepted: `SQL`)
2. `' OR '1'='1`
3. `Admin panel` (also accepted: `admin`)
4. `FLAG{v4l1d4t3_1nputs}`

Enter the training input in the browser mockup, sign in, then open the
simulated Inspect panel to reveal the flag.

### Room 3: Pick the Right Exploit

This room has no typed answers. Select the `FTP` service whose banner says
`Anonymous login enabled`, select `Anonymous FTP login`, and click `Match & Test`.

Flag: `FLAG{r34d_th3_b4nn3r}`

### Room 4: SOC Dashboard Defense — Build the Case

This room has no typed answers. Expand each traffic entry, select at least two
signals, and commit blocks only for the two entries showing correlated attack
patterns. Ignore the legitimate employee entries, including the late-night
login with a confirmed shift.

Flag: `FLAG{d3f3nd_th3_l0g5}`

### Room 5: Red Team, Then Blue Team

This room has no typed answers. Select the correct option at each decision:

1. Anonymous file share
2. Browse the shared files
3. Extract the training record
4. Patch the anonymous share permissions
5. Require authentication for the share
6. Run the safe re-test

Flags: `FLAG{r3d_t3am_c4ptur3}` and `FLAG{blu3_t3am_f1x3d}`
