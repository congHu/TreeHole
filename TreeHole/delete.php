<?php
    $tid = $_GET['tid'];
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    $query = mysql_query("select tid from tc where tid='$tid'");
    $res = mysql_fetch_array($query);
    
    if($res){
        mysql_query("delete from tc where tid=$tid");
    }
    mysql_close($sql);
?>