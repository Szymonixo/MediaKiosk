<?php
// List all files in the 'media' folder
$mediaDir = __DIR__ . '/media';
$files = [];
$fileslist = "";
if (is_dir($mediaDir)) {
    foreach (scandir($mediaDir) as $file) {
        if ($file !== '.' && $file !== '..') {
            $files[] = $file;
        }
    }
}

if(count($files) > 0)
{
    foreach ($files as $file) 
    {
        $fileslist .= "<li><a href='media/".$file."'>".$file."</a> <form action='delete.php' method='post'><input type='hidden' name='filename' value='".$file."'><input type='submit' value='Delete'></form></li>";
    }
} 
else
{
    $fileslist = "<p>No files found in the media directory.</p>";
}

?>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kiosk Management</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <main>
        <h1>Kiosk Management</h1>
        <p>Manage your kiosk files here. You can upload new files or delete existing ones.</p>
        <h2>Existing Files</h2>
        <ul id="file-list">
            <?php echo $fileslist; ?>
        </ul>
    <h2>Upload new files:</h2>
<form action="upload.php" method="post" enctype="multipart/form-data">
    <input type="file" accept="image/*,video/*" multiple name="files[]">
    <input type="submit" value="Upload">
</form>
</main>
  
</body>
</html>