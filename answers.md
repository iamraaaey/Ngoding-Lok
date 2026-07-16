# Ngoding Lok Curriculum: Solved Level Solutions

This document contains working solutions for every playable lesson, grouped by
the in-app learning track. Grid and rocket commands use the app's shared
training DSL; they are not full Python or Java compilers.

---

## Python Track Solutions

### Module 1: Sequential Steps

- **Objective**: Move the player to `(3,3)` on a `5x5` grid from `(0,0)`.
- **Solution**:

  ```python
  move.right();
  move.right();
  move.right();
  move.down();
  move.down();
  move.down();
  ```

### Module 3: Aerospace Logic

- **Objective**: Complete preflight, start the engine, and reach `100km` altitude.
- **Solution**:

  ```python
  sys.preflight();
  engine.start();
  throttle(500);
  ```

### Module 4: Backtrack Basics

- **Objective**: Start at `(4,4)` and reach `(0,0)` with four left and four up moves.
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

- **Objective**: Move from `(0,0)` to `(6,6)` on a `7x7` grid.
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

### Module 7: High Orbit

- **Objective**: Complete preflight, start the engine, and reach `250km` altitude.
- **Solution**:

  ```python
  sys.preflight();
  engine.start();
  throttle(1250);
  ```

### Module 8: Center Escape

- **Objective**: Move from `(2,2)` to `(5,0)`.
- **Solution**:

  ```python
  move.right();
  move.right();
  move.right();
  move.up();
  move.up();
  ```

### Module 10: Gravity Well

- **Objective**: Escape the gravity well by reaching `400km` altitude.
- **Solution**:

  ```python
  sys.preflight();
  engine.start();
  throttle(2000);
  ```

### Module 11: The Grand Maze

- **Objective**: Move from `(7,0)` to `(0,7)`.
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

### Module 13: Escape Velocity

- **Objective**: Complete the graduation flight at `600km` altitude.
- **Solution**:

  ```python
  sys.preflight();
  engine.start();
  throttle(3000);
  ```

---

## SQL Track Solutions

### Module 2: Intro to SQL

- **Objective**: Find the password for the `admin` user.
- **Solution**:

  ```sql
  SELECT password FROM users WHERE role = 'admin';
  ```

### Module 6: Filtering 101

- **Objective**: List student names where the grade is `A`.
- **Solution**:

  ```sql
  SELECT name FROM students WHERE grade = 'A';
  ```

### Module 9: Sorting Secrets

- **Objective**: Rank the tournament board from highest to lowest score.
- **Solution**:

  ```sql
  SELECT * FROM scores ORDER BY points DESC;
  ```

### Module 12: Counting Heads

- **Objective**: Aggregate the player count.
- **Solution**:

  ```sql
  SELECT COUNT(*) FROM players;
  ```

### SQL Level 5: Filtering with WHERE

- **Objective**: List student names where the grade is `A`.
- **Solution**:

  ```sql
  SELECT name FROM students WHERE grade = 'A';
  ```

---

## Java Track Solutions

### Java Level 1: Variables & Method Calls

- **Objective**: Move the player to `(3,3)` on a `5x5` grid from `(0,0)`.
- **Solution**:

  ```java
  move.right();
  move.right();
  move.right();
  move.down();
  move.down();
  move.down();
  ```

### Java Level 3: Space Object Control

- **Objective**: Complete spacecraft preflight, start engines, and reach `150km` altitude.
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
