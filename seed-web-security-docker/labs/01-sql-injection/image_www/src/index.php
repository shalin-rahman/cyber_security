<?php
session_start();
$conn = new mysqli(getenv('MYSQL_HOST') ?: '10.9.0.6', 'root', 'dees', 'sqllab_users');
if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEED Labs — SQL Injection Attack Lab</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f6f9; }
        .container { max-width: 800px; margin: auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #4A90E2; padding-bottom: 10px; }
        .card { background: #f9f9f9; padding: 20px; border: 1px solid #e1e1e1; margin-bottom: 20px; border-radius: 5px; }
        input[type=text], input[type=password] { width: 70%; padding: 10px; margin: 8px 0; border: 1px solid #ccc; border-radius: 4px; }
        input[type=submit] { background: #4A90E2; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background: #4A90E2; color: white; }
        .alert { padding: 12px; background: #d4edda; color: #155724; border-radius: 4px; margin-bottom: 15px; }
    </style>
</head>
<body>
<div class="container">
    <h1>SEED Labs — SQL Injection Vulnerable Application</h1>

    <?php if (isset($_SESSION['user'])): ?>
        <div class="alert">Logged in as: <strong><?php echo htmlspecialchars($_SESSION['user']); ?></strong> | <a href="?logout=1">Logout</a></div>
    <?php endif; ?>

    <?php
    if (isset($_GET['logout'])) {
        session_destroy();
        header("Location: index.php");
        exit;
    }
    ?>

    <!-- Task 2.1: Login Form (Vulnerable) -->
    <div class="card">
        <h2>Task 2.1: Employee Login (Vulnerable)</h2>
        <form method="POST" action="index.php">
            <input type="hidden" name="action" value="login">
            <label>Username:</label><br>
            <input type="text" name="username" placeholder="e.g. alice or admin'#"><br>
            <label>Password:</label><br>
            <input type="password" name="password" placeholder="Password"><br><br>
            <input type="submit" value="Login">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'login') {
            $username = $_POST['username'];
            $password = $_POST['password'];

            // =========================================================================
            // VULNERABILITY: Raw String Concatenation (SQL Injection)
            // =========================================================================
            // DEFINITION: SQL Injection occurs when untrusted user input is directly
            // appended into a database query string. The database engine cannot distinguish
            // between the intended query logic and the attacker's payload.
            //
            // EXAMPLE: If username is "admin'#"
            // The query becomes: SELECT * FROM credential WHERE Name='admin'#' AND Password='...'
            // The '#' comments out the password check, bypassing authentication entirely.
            // =========================================================================
            $sql = "SELECT * FROM credential WHERE Name='$username' AND Password='$password'";
            echo "<p><strong>Executed SQL Query:</strong> <code>" . htmlspecialchars($sql) . "</code></p>";

            $result = $conn->query($sql);
            if ($result && $result->num_rows > 0) {
                $row = $result->fetch_assoc();
                $_SESSION['user'] = $row['Name'];
                echo "<div class='alert'>Authentication Successful! Welcome, " . htmlspecialchars($row['Name']) . ".</div>";
            } else {
                echo "<p style='color:red;'>Authentication Failed.</p>";
            }
        }
        ?>
    </div>

    <!-- Task 2.2: Employee Search (Vulnerable) -->
    <div class="card">
        <h2>Task 2.2: Employee Profile Search (Vulnerable)</h2>
        <form method="GET" action="index.php">
            <label>Employee Name:</label><br>
            <input type="text" name="E_Name" value="<?php echo isset($_GET['E_Name']) ? htmlspecialchars($_GET['E_Name']) : ''; ?>" placeholder="e.g. Alice or Alice'#">
            <input type="submit" value="Search">
        </form>

        <?php
        if (isset($_GET['E_Name'])) {
            $name = $_GET['E_Name'];

            // Vulnerable Query Construction
            $sql = "SELECT ID, Name, EID, Salary, Birthday, SSN, PhoneNumber, Address, Email FROM credential WHERE Name='$name'";
            echo "<p><strong>Executed SQL Query:</strong> <code>" . htmlspecialchars($sql) . "</code></p>";

            $result = $conn->query($sql);
            if ($result && $result->num_rows > 0) {
                echo "<table><tr><th>ID</th><th>Name</th><th>EID</th><th>Salary ($)</th><th>SSN</th><th>Email</th></tr>";
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . htmlspecialchars($row['ID']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['Name']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['EID']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['Salary']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['SSN']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['Email']) . "</td>";
                    echo "</tr>";
                }
                echo "</table>";
            } else {
                echo "<p style='color:red;'>No records found.</p>";
            }
        }
        ?>
    </div>

    <!-- Task 3: Edit Profile / Salary (Vulnerable UPDATE Injection) -->
    <div class="card">
        <h2>Task 3: Update Profile Data (Vulnerable UPDATE)</h2>
        <form method="POST" action="index.php">
            <input type="hidden" name="action" value="update">
            <label>Target Name:</label><br>
            <input type="text" name="name" placeholder="Name (e.g. Alice)"><br>
            <label>New Salary ($):</label><br>
            <input type="text" name="salary" placeholder="New Salary"><br><br>
            <input type="submit" value="Update Profile">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update') {
            $name = $_POST['name'];
            $salary = $_POST['salary'];

            // Vulnerable UPDATE statement
            $sql = "UPDATE credential SET Salary=$salary WHERE Name='$name'";
            echo "<p><strong>Executed SQL Query:</strong> <code>" . htmlspecialchars($sql) . "</code></p>";

            if ($conn->query($sql) === TRUE) {
                echo "<div class='alert'>Profile updated successfully.</div>";
            } else {
                echo "<p style='color:red;'>Update Error: " . htmlspecialchars($conn->error) . "</p>";
            }
        }
        ?>
    </div>

    <!-- Task 4: Prepared Statements (Secure Search Countermeasure) -->
    <div class="card">
        <h2>Task 4: Secure Search (Prepared Statements Countermeasure)</h2>
        <form method="GET" action="index.php">
            <label>Employee Name (Secure):</label><br>
            <input type="text" name="safe_name" value="<?php echo isset($_GET['safe_name']) ? htmlspecialchars($_GET['safe_name']) : ''; ?>" placeholder="e.g. admin'#">
            <input type="submit" value="Secure Search">
        </form>

        <?php
        if (isset($_GET['safe_name'])) {
            $name = $_GET['safe_name'];

            // =========================================================================
            // FIX: Parameterized Queries (Prepared Statements)
            // =========================================================================
            // DEFINITION: Prepared statements separate the SQL code structure from the
            // user-provided data. The query is pre-compiled by the database engine FIRST,
            // and then the user input is inserted strictly as literal values.
            //
            // RESULT: If name is "admin'#", the database looks for a user whose literal
            // name is exactly "admin'#", rather than executing it as SQL syntax.
            // =========================================================================
            $stmt = $conn->prepare("SELECT ID, Name, EID, Salary, SSN, Email FROM credential WHERE Name=?");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $result = $stmt->get_result();

            echo "<p><strong>Secure Prepared Query Executed with bound parameter:</strong> <code>" . htmlspecialchars($name) . "</code></p>";

            if ($result && $result->num_rows > 0) {
                echo "<table><tr><th>ID</th><th>Name</th><th>EID</th><th>Salary ($)</th><th>SSN</th><th>Email</th></tr>";
                while ($row = $result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . htmlspecialchars($row['ID']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['Name']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['EID']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['Salary']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['SSN']) . "</td>";
                    echo "<td>" . htmlspecialchars($row['Email']) . "</td>";
                    echo "</tr>";
                }
                echo "</table>";
            } else {
                echo "<p style='color:red;'>No records found (Injection payload treated as literal string data).</p>";
            }
        }
        ?>
    </div>
</div>
</body>
</html>
