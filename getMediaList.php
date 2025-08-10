<?php

$flies = [];
$mediaDir = __DIR__ . '/media';
foreach (scandir($mediaDir) as $file) {
    if ($file !== '.' && $file !== '..') {
        $flies[] = $file;
    }
}
echo $flies ? json_encode($flies) : json_encode([]);




?>