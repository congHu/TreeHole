<?php
    $tid = $_GET['tid'];
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    $query = mysql_query("select tid from tipoff where tid='$tid'");
    $res = mysql_fetch_array($query);
    
    if(!$res){
        mysql_query("insert into tipoff (tid) values ($tid)");
    }else{
        mysql_query("update tipoff set tiptime=tiptime+1 where tid='$tid'");
        
    }
    mysql_close($sql);
    ?>