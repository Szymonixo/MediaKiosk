<?php
if ($_FILES)
{
    $targetDir = __DIR__ . '/media/';
    $files = $_FILES['files'];
    foreach ($files['name'] as $key => $name) {
        $targetFile = $targetDir . basename($name);
        if (move_uploaded_file($files['tmp_name'][$key], $targetFile)) {
            echo "The file " . htmlspecialchars($name) . " has been uploaded successfully.<br>";
            header("Location: index.php");
        } else {
            echo "Sorry, there was an error uploading your file: " . htmlspecialchars($name) . "<br>";
        }
    }
} else {
    echo "No files were uploaded.";
}
?>