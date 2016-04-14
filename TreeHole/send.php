<?php
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    $content = $_POST['content'];
    $color = $_POST['color'];
    $uid = $_POST['uid'];
    mysql_query("insert into tc (tCon,tColor,tDate,ubelong) values ('$content','$color',now(),'$uid')");
    mysql_close($sql);
?>