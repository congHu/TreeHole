<?php
    $index = $_GET['index'];
    $userid = $_GET['userid'];
    $sql = mysql_connect("127.0.0.1","root","");
    if (!$sql)
    {
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db("treehole",$sql);
    $maxid = mysql_query("select max(tid) from tc");
    $row = mysql_fetch_array($maxid);
    $tid = $row['max(tid)'];
    $existID = array();
    for($i=0;$i<$index;$i++){
        
        $hasRes = mysql_query("select * from tc where tid='$tid' and ubelong='$userid'");
        $hasAry = mysql_fetch_array($hasRes);
        while(!$hasAry){
            $tid--;
            if($tid<1){
                break;
            }
            $hasRes = mysql_query("select * from tc where tid='$tid' and ubelong='$userid'");
            $hasAry = mysql_fetch_array($hasRes);
        }
        
        $tid--;
    }
    $res = mysql_query("select * from uid$userid");
    $likeAry = array();
    while($row = mysql_fetch_array($res)){
        $likeAry[] = $row;
    }
    for($i=0;$i<10;$i++){
        
        $hasRes = mysql_query("select * from tc where tid='$tid' and ubelong='$userid'");
        $hasAry = mysql_fetch_array($hasRes);
        while(!$hasAry){
            $tid--;
            if($tid<1){
                break;
            }
            $hasRes = mysql_query("select * from tc where tid='$tid' and ubelong='$userid'");
            $hasAry = mysql_fetch_array($hasRes);
        }
        foreach($likeAry as $likeid){
            if($likeid['likeid']==$tid) {
                $hasAry['ulike'] = true;
                break;
            }
            
        }
        $existID[] = $hasAry;
        $tid--;
    }
    $json = json_encode($existID);
    echo preg_replace("#\\\u([0-9a-f]{4})#ie", "iconv('UCS-2BE', 'UTF-8', pack('H4', '\\1'))", $json);
    mysql_close($sql);
    ?>