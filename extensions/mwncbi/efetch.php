<?php

function echoEmpty($message)
	{
	echo "<?xml version='1.0'?>\n<Error>".$message;
	foreach($_POST as $k=>$v) echo "* ".$k."=".$v." ";
	echo "</Error>\n"
		;

	}

header("Content-type: text/xml");
$id=0;

if (empty($_POST))
	{
	echoEmpty("POST empty");
	return;
	}

if(!isset($_POST["db"]) || !isset($_POST["id"]) || ($id=intval($_POST["id"]))<=0)
	{
	echoEmpty("bad url db=".$_POST["db"]." id=".$_POST["id"]." or  ".
		$_POST["id"]." ".$HTTP_RAW_POST_DATA);
	return;
	}

$in = fopen(
	"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=".
		urlencode($_POST["db"]).
		"&retmode=xml&id=".$id,
	"r");
	
if(!$in)
	{
	echoEmpty("cannot open url");
	return;
	}
stream_set_timeout($in, 1);
while (!feof($in))
	{
        echo fgets($in, 2048);
    	}
fclose($in);
?>