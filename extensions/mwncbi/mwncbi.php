<?php
/**
Author:
	Pierre Lindenbaum PhD
Contact:
	plindenbaum@yahoo.fr
	http://plindenbaum.blogpost.com

**/



if (!defined('MEDIAWIKI')){
        die('not a standalone program');
}
 
/**
 * Protect against register_globals vulnerabilities.
 * This line must be present before any global variable is referenced.
**/
if(!defined('MEDIAWIKI')){
        echo("This is an extension to the MediaWiki package and cannot be run standalone.\n" );
        die(-1);
}


/* Avoid unstubbing $wgParser on setHook() too early on modern (1.12+) MW versions */
if (!defined( 'MW_SUPPORTS_PARSERFIRSTCALLINIT' ) )
	{
        echo("This has not been tested for this version of mediawiki.\n" );
        die(-1);
	}



global $wgHooks;


$wgHooks['ParserFirstCallInit'][] = 'mwncbiFirstCallInit';
$wgHooks['BeforePageDisplay'][]  = 'mwncbiBeforePageDisplay';
 
function mwncbiBeforePageDisplay($out)
	{
	global $wgScriptPath;
	$out->addScript('<link rel="stylesheet" type="text/css" href="'.$wgScriptPath.'/extensions/mwncbi/mwncbi.css"></link>\n');
	$out->addScript('<script type="text/javascript" src="'.$wgScriptPath.'/extensions/mwncbi/mwncbi.js"></script>\n');
	$out->addScript("<script type='text/javascript'>".
		"MWNCBI.wgScriptPath=\"".addslashes($wgScriptPath)."/extensions/mwncbi\";".
		"this.addEventListener('load', MWNCBI.runmwncbi, false);".
		"</script>\n");
	return true;
	}


/**
 * An array of extension types and inside that their names, versions, authors and urls. This credit information gets added to the wiki's Special:Version page, allowing users to see which extensions are installed, and to find more information about them.
**/
$wgExtensionCredits['parserhook'][] = array(
        'name'          =>      'mwncbi',
        'version'       =>      '0.1',
        'author'        =>      '[http://plindenbaum.blogspot.com Pierre Lindenbaum]',
        'url'           =>      'http://plindenbaum.blogspot.com',
        'description'   =>      'Embbed Some records from the NCBI (pubmed, gene, snp) as HTML'
	);

function mwncbiFirstCallInit()
        {
        global $wgParser;
        $wgParser->setHook( 'ncbisnp', 'myRenderNCBISNP' );
        $wgParser->setHook( 'ncbigene', 'myRenderNCBIGENE' );
        $wgParser->setHook( 'ncbipubmed', 'myRenderNCBIPUBMED' );
        return true;
        }

function myRenderNCBIXXX( $input, $args, $parser,$prefix)
	{
	if( !(isset($args['id']))) return "<span style='color:red;'>id missing</span>";
	$id=(int)trim($args['id']);
	if(!is_int($id)) return      "<span style='color:red;'>bad @id</span>";
	$html=  "<div link='".$prefix.":".$id."' class='mwncbi'>".$prefix.":".$id."</div>";
        return $html;
	}

function myRenderNCBISNP( $input, $args, $parser )
        {
        return myRenderNCBIXXX($input, $args, $parser,"snp");
        }
        
function myRenderNCBIPUBMED( $input, $args, $parser )
        {
        return myRenderNCBIXXX($input, $args, $parser,"pubmed");
        }
        
function myRenderNCBIGENE( $input, $args, $parser )
        {
        return myRenderNCBIXXX($input, $args, $parser,"gene");
        }


?>