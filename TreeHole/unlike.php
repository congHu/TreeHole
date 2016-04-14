<?php
    $textid = $_GET['textid'];
    $userid = $_GET['userid'];
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    $query = mysql_query("select likeid from uid$userid where likeid=$textid");
    $res = mysql_fetch_array($query);
    if($res){
        mysql_query("delete from uid$userid where likeid='$textid'");
        mysql_query("update tc set tlike=tlike-1 where tid=$textid");
    }
    
    mysql_close($sql);
    ?>