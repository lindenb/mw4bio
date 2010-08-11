var MWNCBI={
processors:new Array(),
wgScriptPath:".",

removeChildren :function(node)
	{
	while(node.hasChildNodes())
		{
		node.removeChild(node.firstChild);
		}
	return node;
	},



applyXSL:function(xmlDoc,index,array)
	{
	var database=array[index].db;
	var processor=MWNCBI.processors[database];
	if(xmlDoc==null) return;
	
	if(processor==undefined)
		{
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function()
		 	{
  			if (xmlhttp.readyState!=4) return;
  				
			if(xmlhttp.status!=200)
				{
				return;
				}
			
			var stylesheet=xmlhttp.responseXML;
			if(stylesheet==null)
				{
				return;
				}
			processor = new XSLTProcessor();  
			processor.importStylesheet(stylesheet);
			MWNCBI.processors[database]=processor;
			MWNCBI.applyXSL(xmlDoc,index,array);
  			};
		
		xmlhttp.open("GET", MWNCBI.wgScriptPath+"/"+database+"2html.xsl", true); 
		xmlhttp.overrideMimeType("text/xml");//not text/html else responseXML is null
		xmlhttp.send(null);
		return;
		}
	
	var fragment= processor.transformToDocument(xmlDoc);
	if(fragment==null) return;
	fragment=document.importNode(fragment.documentElement,true);
	MWNCBI.removeChildren(array[index].element);
	array[index].element.appendChild(fragment);
	MWNCBI.getGene(index+1,array);
	},

getGene:function(index,array)
	{
	if(index>=array.length) return;
	
	try 	{
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function()
		 	{
  			if (xmlhttp.readyState!=4) return;
  				
			if(xmlhttp.status!=200)
				{
				MWNCBI.removeChildren(array[index].element).appendChild(document.createTextNode("ERROR status:"+xmlhttp.status));
				return;
				}
			
			MWNCBI.applyXSL(xmlhttp.responseXML,index,array);
  			};
		xmlhttp.open("POST", MWNCBI.wgScriptPath+"/efetch.php", true);
		xmlhttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		var params="id=" + escape(array[index].id)+"&db="+array[index].db;
		xmlhttp.send(params); 
		} 
	catch (e)
		{
		alert(e);
		}

	},

runmwncbi:function()
	{
	var array=new Array();
	var i;
	var divs=document.getElementsByTagName("div");
	
	for(i=0;i < divs.length; ++i)
		{
		var div=divs[i];
		if(div.getAttribute("class")!="mwncbi") continue;
		var link=div.getAttribute("link");
		if(link==null) continue;
		var j=link.indexOf(':');
		if(j==-1) continue;
		var database=link.substr(0,j);
		if(!(database=="gene" || database=="snp"|| database=="pubmed")) continue;
		var geneid=link.substr(j+1);
		MWNCBI.removeChildren(div);
		var img=document.createElementNS("http://www.w3.org/1999/xhtml","img");
		img.setAttribute("src",MWNCBI.wgScriptPath+"/wait.gif");
		img.setAttribute("title","wait for "+geneid);
		div.appendChild(img);
		array[array.length]={element:div,id:geneid,db:database};
		}
	MWNCBI.getGene(0,array);
	}
};
