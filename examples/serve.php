<?php
$root_dir = "/var/www/vhosts/domain.com/tvsh/clips";
$index = "$root_dir/index";

$random = $_GET["random"];
$id = $_GET["id"];
$duration = $_GET["duration"];
if (!isset($duration)) {
  $duration = 0;
};

function get_random_file($dura = 0) {
    global $root_dir, $index;

    $lines = file($index, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

    if ($dura > 0) {
        $filtered = array_filter($lines, function($line) use ($dura) {
            $parts = explode(';', $line);
            return count($parts) === 2 && intval($parts[1]) >= $dura;
        });
        $lines = array_values($filtered);
    }

    if (empty($lines)) {
        return null;
    }

    $random_line = $lines[array_rand($lines)];
    $parts = explode(';', $random_line);
    return [ $parts[0], $parts[1] ];
}

if (isset($random)) {
  [$fname, $dura] = get_random_file($duration);
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
