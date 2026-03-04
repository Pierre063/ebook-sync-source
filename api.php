<?php
// /public_html/scorm-sync/api.php
// Mini API REST: stocke/retourne l'état d'une "room" dans un fichier JSON
// Exemples:
//   GET  /scorm-sync/api.php?org=ivry_rh&sco=journee_filtering&room=demo
//   POST /scorm-sync/api.php (JSON body: { org, sco, room, state })

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');           // durcir en prod (CSP/Origin)
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

// --- config ---
$DATA_DIR = __DIR__ . '/data';
if (!is_dir($DATA_DIR)) { mkdir($DATA_DIR, 0755, true); }

// --- helpers ---
function sanitize($s) {
  return preg_replace('/[^a-zA-Z0-9_-]/', '_', $s ?? '');
}
function store_path($org, $sco, $room) {
  global $DATA_DIR;
  $org  = sanitize($org);
  $sco  = sanitize($sco);
  $room = sanitize($room);
  $path = "$DATA_DIR/$org/$sco";
  if (!is_dir($path)) { mkdir($path, 0755, true); }
  return "$path/$room.json";
}

// --- routes ---
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
  $org  = $_GET['org']  ?? '';
  $sco  = $_GET['sco']  ?? '';
  $room = $_GET['room'] ?? '';
  if (!$org || !$sco || !$room) { http_response_code(400); echo json_encode(['error'=>'missing params']); exit; }

  $file = store_path($org, $sco, $room);
  if (!file_exists($file)) { 
    // init état par défaut si absent
    $default = ['participants'=>[], 'activePid'=>'1', 'adminUnlocked'=>false];
    file_put_contents($file, json_encode($default, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE));
  }

  // Lecture avec verrou (pour éviter une écriture concurrente)
  $fp = fopen($file, 'r'); if (!$fp) { http_response_code(500); echo json_encode(['error'=>'cannot open']); exit; }
  flock($fp, LOCK_SH);
  $raw = stream_get_contents($fp);
  flock($fp, LOCK_UN);
  fclose($fp);

  echo $raw ?: json_encode(['participants'=>[], 'activePid'=>'1', 'adminUnlocked'=>false]);
  exit;
}

if ($method === 'POST') {
  $data = json_decode(file_get_contents('php://input'), true);
  $org  = $data['org']  ?? '';
  $sco  = $data['sco']  ?? '';
  $room = $data['room'] ?? '';
  $state= $data['state']?? null;

  if (!$org || !$sco || !$room || !is_array($state)) { http_response_code(400); echo json_encode(['error'=>'bad payload']); exit; }

  $file = store_path($org, $sco, $room);

  // Écriture atomique avec verrouillage
  $tmp = $file . '.tmp';
  $fp = fopen($tmp, 'w'); if (!$fp) { http_response_code(500); echo json_encode(['error'=>'cannot temp write']); exit; }
  flock($fp, LOCK_EX);
  fwrite($fp, json_encode($state, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE));
  fflush($fp);
  flock($fp, LOCK_UN);
  fclose($fp);

  rename($tmp, $file);
  echo json_encode(['ok'=>true]);
  exit;
}

http_response_code(405);
echo json_encode(['error'=>'method not allowed']);