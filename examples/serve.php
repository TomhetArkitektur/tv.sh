<?php
$root_dir = "/var/www/vhosts/domain.com/tvsh/clips";
$index_file = "$root_dir/index";

$min_duration = isset($_GET["min_duration"]) ? (int)$_GET["min_duration"] : 0;
$max_duration = isset($_GET["max_duration"]) ? (int)$_GET["max_duration"] : 0;
$id = isset($_GET["id"]) ? (int)$_GET["id"] : 0;
$is_random = isset($_GET["random"]);

function get_random_file($index, $min_dura, $max_dura) {
  if (!file_exists($index)) return null;

  $handle = fopen($index, "r");
  $candidates = [];

  if ($handle) {
    while (($line = fgets($handle)) !== false) {
      $line = trim($line);
      if (empty($line)) continue;

      $parts = explode(';', $line);
      if (count($parts) < 2) continue;

      $dura = (int)$parts[1];
      if ($min_dura > 0 && $dura < $min_dura) continue;
      if ($max_dura > 0 && $dura > $max_dura) continue;

      $candidates[] = [$parts[0], $dura];
    }
    fclose($handle);
  }

  if (empty($candidates)) return null;

  return $candidates[array_rand($candidates)];
}

if ($is_random) {
  [$fname, $dura] = get_random_file($index_file, $min_duration, $max_duration);
  $data = array("url" => "http://domain.com/tvsh/clips/$fname", "duration" => $dura);

  header('Content-Type: application/json');
  echo json_encode($data);

  exit;
}

$fname = get_random_file();
echo "<html><body>
  <center>
    <img width=\"800\" height=\"800\" src=\"http://domain.com/tvsh/clips/$fname\"></img>
  </center>
</body></html>";

?>
