<?php
/*
 * SEED Labs — CSRF Target Site (Elgg stub)
 *
 * Tasks implemented here:
 *   Task 2  — GET forged request handled (addfriend)
 *   Task 3  — POST forged request handled (update_profile)
 *   Task 5  — CSRF token countermeasure (toggle $CSRF_PROTECTION)
 *   Task 6  — SameSite cookie attribute (toggle $SAMESITE)
 *
 * Learning notes:
 *   - With $CSRF_PROTECTION = false and $SAMESITE = 'None':
 *       Tasks 2 & 3 attacks succeed (forged requests accepted).
 *   - With $CSRF_PROTECTION = true:
 *       POST attacks fail because the CSRF token is missing from forged requests.
 *   - With $SAMESITE = 'Strict':
 *       The browser will NOT attach the session cookie on cross-site requests,
 *       so ALL cross-origin attacks (GET & POST) fail silently.
 */

// ── Task 5 toggle ─────────────────────────────────────────────────────────────
// Set to true to enable CSRF token validation (fixes Tasks 2/3 POST attacks).
$CSRF_PROTECTION = false;

// ── Task 6 toggle ─────────────────────────────────────────────────────────────
// Options: 'None' (vulnerable), 'Lax' (partial), 'Strict' (fully protected).
$SAMESITE = 'None';

// Apply SameSite + Secure attributes before session_start().
session_set_cookie_params([
    'samesite' => $SAMESITE,
    'secure'   => false,   // set true in production HTTPS
    'httponly' => true,
]);
session_start();

// Database connection
$conn = new mysqli(getenv('MYSQL_HOST') ?: '10.9.0.6', 'root', 'seedubuntu', 'elgg_csrf');
if ($conn->connect_error) {
    die("DB Connection failed: " . $conn->connect_error);
}

// Auto-login as Alice (victim) for testing
if (!isset($_SESSION['user'])) {
    $_SESSION['user']    = 'alice';
    $_SESSION['user_id'] = 56;
}

// ── Task 5: Generate CSRF token ───────────────────────────────────────────────
if (!isset($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// ── Action handlers ───────────────────────────────────────────────────────────
$action_result = '';

// Task 2 — GET: Add Friend (intentionally no CSRF token check on GET to show GET attack)
if (isset($_GET['action']) && $_GET['action'] === 'addfriend') {
    $friend_id     = (int)$_GET['friend'];
    $action_result = "<p class='success'>[Task 2 — GET Attack] Friend ID $friend_id added to {$_SESSION['user']}'s friend list! (No token needed for GET)</p>";
}

// Task 3 / Task 5 — POST: Update Profile
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update_profile') {
    if ($CSRF_PROTECTION) {
        // Task 5: Validate token
        $submitted_token = $_POST['csrf_token'] ?? '';
        if (!hash_equals($_SESSION['csrf_token'], $submitted_token)) {
            $action_result = "<p class='error'>[Task 5 — CSRF Token Defence] ❌ Invalid/missing CSRF token! Request REJECTED. This is what proper protection looks like.</p>";
        } else {
            $bio           = htmlspecialchars($_POST['bio']);
            $action_result = "<p class='success'>[Task 3 — POST] ✅ Token valid. Profile bio updated to: $bio</p>";
        }
    } else {
        // Task 3: No protection — forged POST succeeds
        $bio           = htmlspecialchars($_POST['bio']);
        $action_result = "<p class='success'>[Task 3 — POST Attack] ⚠️ No token check! Profile bio forged to: $bio</p>";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEED Labs — CSRF Target Site (Elgg)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #eef2f5; }
        .container { max-width: 860px; margin: auto; background: white; padding: 30px;
                     border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1  { color: #2C3E50; border-bottom: 2px solid #3498DB; padding-bottom: 10px; }
        h2  { color: #34495e; }
        .card { background: #fafafa; padding: 20px; border: 1px solid #ddd;
                margin-bottom: 20px; border-radius: 5px; }
        .badge   { background: #27AE60; color: white; padding: 5px 10px;
                   border-radius: 3px; font-weight: bold; }
        .success { color: #27ae60; font-weight: bold; }
        .error   { color: #e74c3c; font-weight: bold; }
        .config  { background: #ecf0f1; padding: 10px 15px; border-radius: 4px;
                   font-family: monospace; margin-bottom: 20px; }
        label    { font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <h1>SEED Labs — CSRF Target Social Network</h1>

    <p>Logged in as: <span class="badge"><?php echo htmlspecialchars($_SESSION['user']); ?> (ID: <?php echo $_SESSION['user_id']; ?>)</span></p>

    <!-- Current defence configuration -->
    <div class="config">
        Task 5 CSRF Token Protection : <strong><?php echo $CSRF_PROTECTION ? 'ENABLED ✅' : 'DISABLED ❌'; ?></strong> &nbsp;|&nbsp;
        Task 6 SameSite Cookie       : <strong><?php echo $SAMESITE; ?></strong>
    </div>

    <?php if ($action_result) echo "<div class='card'>$action_result</div>"; ?>

    <!-- Task 2: GET attack surface -->
    <div class="card">
        <h2>Task 2 — Add Friend (GET)</h2>
        <p>Forged GET URL (sent via &lt;img&gt; from attacker page):</p>
        <code>http://www.seed-server.com/index.php?action=addfriend&amp;friend=59</code>
        <p>SameSite=<?php echo $SAMESITE; ?> → cookie <?php echo $SAMESITE === 'Strict' ? '<strong>NOT sent</strong> (attack blocked by SameSite)' : '<strong>sent automatically</strong> (attack succeeds)'; ?></p>
    </div>

    <!-- Task 3: POST attack surface -->
    <div class="card">
        <h2>Task 3 — Update Profile Bio (POST)</h2>
        <form method="POST" action="/index.php">
            <input type="hidden" name="action" value="update_profile">
            <?php if ($CSRF_PROTECTION): ?>
            <!-- Task 5: Embed the secret token — forged requests won't have it -->
            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
            <?php endif; ?>
            <label for="bio">Bio:</label><br>
            <input id="bio" type="text" name="bio" value="Hello from Alice" style="width:100%;padding:8px;margin:8px 0;">
            <button type="submit">Update Bio (Legitimate Request)</button>
        </form>
        <?php if ($CSRF_PROTECTION): ?>
        <p><em>Token is embedded. A forged POST from the attacker site will lack it → rejected.</em></p>
        <?php else: ?>
        <p><em>No token. A forged POST will be accepted → visit <a href="http://www.attacker32.com:10083" target="_blank">attacker site</a> to see.</em></p>
        <?php endif; ?>
    </div>

    <!-- Task 4 link -->
    <div class="card">
        <h2>Task 4 — Same-Domain CSRF Bypass</h2>
        <p>Visit <a href="/csrf_task4.php">/csrf_task4.php</a> to see how a forged form on the same domain bypasses a Referer-only defence.</p>
    </div>

    <!-- Task 6 explanation -->
    <div class="card">
        <h2>Task 6 — SameSite Cookie Attribute</h2>
        <p>Current setting: <code>SameSite=<?php echo $SAMESITE; ?></code></p>
        <ul>
            <li><code>None</code> → cookie sent on all cross-site requests → vulnerable</li>
            <li><code>Lax</code>  → cookie sent on top-level GETs only → GET attacks succeed, POST blocked</li>
            <li><code>Strict</code> → cookie never sent cross-site → all CSRF attacks blocked</li>
        </ul>
        <p>To test: change <code>$SAMESITE</code> in <code>index.php</code> and reload. Observe whether the attacker page can trigger actions.</p>
    </div>
</div>
</body>
</html>
