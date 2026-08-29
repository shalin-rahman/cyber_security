<?php
session_start();
$conn = new mysqli(getenv('MYSQL_HOST') ?: '10.9.0.6', 'root', 'seedubuntu', 'elgg');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEED Labs — Cross-Site Scripting (XSS) Attack Lab</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f4f6f9; }
        .container { max-width: 800px; margin: auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #E74C3C; padding-bottom: 10px; }
        .card { background: #f9f9f9; padding: 20px; border: 1px solid #e1e1e1; margin-bottom: 20px; border-radius: 5px; }
        input[type=text], textarea { width: 90%; padding: 10px; margin: 8px 0; border: 1px solid #ccc; border-radius: 4px; }
        input[type=submit] { background: #E74C3C; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
        .profile { border-left: 4px solid #E74C3C; padding-left: 15px; margin-top: 15px; }
    </style>
</head>
<body>
<div class="container">
    <h1>SEED Labs — XSS Social Network (Elgg Simulation)</h1>

    <div class="card">
        <h2>Update Profile "About Me" (Vulnerable Stored XSS)</h2>
        <form method="POST" action="index.php">
            <label>Select User:</label><br>
            <select name="username">
                <option value="samy">Samy (Attacker)</option>
                <option value="alice">Alice (Victim)</option>
                <option value="boby">Boby</option>
            </select><br><br>
            <label>About Me (XSS Payload Input):</label><br>
            <textarea name="profile_about" rows="4" placeholder="Enter bio or <script>alert('XSS')</script>"></textarea><br>
            <input type="submit" value="Save Profile">
        </form>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['profile_about'])) {
            $user = $_POST['username'];
            $about = $_POST['profile_about'];

            // Vulnerable: Stored raw HTML/JS without escaping
            $stmt = $conn->prepare("UPDATE users SET profile_about = ? WHERE username = ?");
            $stmt->bind_param("ss", $about, $user);
            $stmt->execute();
            echo "<p style='color:green;'>Profile for " . htmlspecialchars($user) . " updated.</p>";
        }
        ?>
    </div>

    <div class="card">
        <h2>View User Profiles</h2>
        <ul>
            <li><a href="?view=alice">View Alice's Profile</a></li>
            <li><a href="?view=samy">View Samy's Profile</a></li>
            <li><a href="?view=boby">View Boby's Profile</a></li>
        </ul>

        <?php
        if (isset($_GET['view'])) {
            $viewUser = $_GET['view'];
            $stmt = $conn->prepare("SELECT name, profile_about FROM users WHERE username = ?");
            $stmt->bind_param("s", $viewUser);
            $stmt->execute();
            $res = $stmt->get_result();

            if ($row = $res->fetch_assoc()) {
                echo "<div class='profile'>";
                echo "<h3>" . htmlspecialchars($row['name']) . "</h3>";
                echo "<p><strong>About Me:</strong></p>";
                // VULNERABLE UNESCAPED OUTPUT rendering raw HTML/JavaScript
                echo "<div>" . $row['profile_about'] . "</div>";
                echo "</div>";
            }
        }
        ?>
    </div>
</div>
</body>
</html>
