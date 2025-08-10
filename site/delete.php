<?php
if($_POST)
{
    $filename = $_POST['filename'];
    $filePath = __DIR__ . '/media/' . $filename;

    if (file_exists($filePath)) {
        if (unlink($filePath)) {
            echo "File deleted successfully.";
            header("Location: index.php");
        } else {
            echo "Error deleting file.";
        }
    } else {
        echo "File does not exist.";
    }
} else {
    echo "No file specified for deletion.";
}

header("Location: index.php");
?>