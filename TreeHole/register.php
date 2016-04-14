<?php
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    mysql_query("update curUser set maxid=maxid+1");
    $result = mysql_query("select maxid from curUser");
    $row = mysql_fetch_array($result);
    $love = $row['maxid'];
    mysql_query("create table uid{$love}(likeid int not null)");
    echo $love;
    mysql_close($sql);
?>