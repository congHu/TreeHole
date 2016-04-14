<?php
    $index = $_GET['index'];
    $userid = $_GET['userid'];
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    $res = mysql_query("select * from uid$userid");
    $likeAry = array();
    while($row = mysql_fetch_array($res)){
        $likeAry[] = $row;
    }
    //echo json_encode($likeAry);
    $existID = array();

    for($i=$index;$i<$index+10;$i++){
        $id = $likeAry[$i]['likeid'];
        $hasRes = mysql_query("select * from tc where tid='$id'");
        $hasAry = mysql_fetch_array($hasRes);
        
        $existID[] = $hasAry;
    }
    $json = json_encode($existID);
    echo preg_replace("#\\\u([0-9a-f]{4})#ie", "iconv('UCS-2BE', 'UTF-8', pack('H4', '\\1'))", $json);
    mysql_close($sql);
    ?>