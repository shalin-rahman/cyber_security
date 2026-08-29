<?php
session_start();
$conn = new mysqli(getenv('MYSQL_HOST') ?: '10.9.0.6', 'root', 'seedubuntu', 'elgg_csrf');
if ($conn->connect_error) {
    die("DB Connection failed: " . $conn->connect_error);
}

// Auto-login as Alice (victim) for testing
if (!isset($_SESSION['user'])) {
    $_SESSION['user'] = 'alice';
    $_SESSION['user_id'] = 56;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEED Labs — CSRF Target Site (Elgg)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #eef2f5; }
        .container { max-width: 800px; margin: auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2C3E50; border-bottom: 2px solid #3498DB; padding-bottom: 10px; }
        .card { background: #fafafa; padding: 20px; border: 1px solid #ddd; margin-bottom: 20px; border-radius: 5px; }
        .badge { background: #27AE60; color: white; padding: 5px 10px; border-radius: 3px; font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <h1>SEED Labs — CSRF Target Social Network</h1>
    <p>Active Logged-in Session: <span class="badge"><?php echo htmlspecialchars($_SESSION['user']); ?> (ID: <?php echo $_SESSION['user_id']; ?>)</span></p>

    <div class="card">
        <h2>Action 1: Add Friend (GET Action)</h2>
        <p>Current Friends: Alice, Boby</p>
        <?php
        if (isset($_GET['action']) && $_GET['action'] === 'addfriend') {
            $friend_id = $_GET['friend'];
            echo "<p style='color:green;font-weight:bold;'>[GET Action Triggered] Friend ID $friend_id added to Alice's friend list!</p>";
        }
        ?>
    </div>

    <div class="card">
        <h2>Action 2: Update Profile Bio (POST Action)</h2>
        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update_profile') {
            $bio = $_POST['bio'];
            echo "<p style='color:green;font-weight:bold;'>[POST Action Triggered] Profile bio updated to: " . htmlspecialchars($bio) . "</p>";
        }
        ?>
    </div>
</div>
</body>
</html>
