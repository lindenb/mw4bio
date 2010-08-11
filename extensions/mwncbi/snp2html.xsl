<?xml version='1.0'  encoding="ISO-8859-1" ?>
<xsl:stylesheet
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:s="http://www.ncbi.nlm.nih.gov/SNP/docsum"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	version='1.0'
	>
<!--
Author:
	Pierre Lindenbaum PhD
	http://plindenbaum.blogspot.com
	plindenbaum@yahoo.fr
Motivation:
	transforms ncbi gene to html


-->


<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" />




<xsl:template match="/">
<div>
<xsl:apply-templates select="s:ExchangeSet|Error"/>
</div>
</xsl:template>

<xsl:template match="Error">
An error occured. <xsl:value-of select="."/>
</xsl:template>


<xsl:template match="s:ExchangeSet">
<div>
<xsl:apply-templates select="s:Rs"/>
</div>
</xsl:template>

<xsl:template match="s:Rs">
<dl>
<dt>Name</dt>
<dd><xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="concat('http://www.ncbi.nlm.nih.gov/projects/SNP/snp_ref.cgi?rs=',@rsId)"/></xsl:attribute>
<xsl:value-of select="concat('rs',@rsId)"/>
</xsl:element></dd>
<dt>Type</dt><dd><xsl:value-of select="@molType"/></dd>
<xsl:apply-templates select="s:Validation"/>
<xsl:apply-templates select="s:Het"/>
<xsl:apply-templates select="s:Sequence"/>
<dt>Mapping</dt><dd><xsl:apply-templates select="s:Assembly"/></dd>
</dl>
</xsl:template>

<xsl:template match="s:Validation">
<dt>Validation</dt><dd>
	<xsl:if test="@byCluster='true'"><xsl:text> Cluster</xsl:text></xsl:if>
	<xsl:if test="@byFrequency='true'"><xsl:text> Frequency</xsl:text></xsl:if>
	<xsl:if test="@byHapMap='true'"><xsl:text> Hapmap</xsl:text></xsl:if>
</dd>
</xsl:template>

<xsl:template match="s:Het">
<dt>Het</dt><dd><xsl:value-of select="@value"/> <xsl:if test="@stdError"> &#177;<xsl:value-of select="@stdError"/></xsl:if></dd>
</xsl:template>


<xsl:template match="s:Sequence">
<dt>Observed</dt><dd><code class="snpObserved"><xsl:value-of select="s:Observed"/></code></dd>
<dt>Sequence</dt><dd>
	<span class="snpSeq"><xsl:call-template name="printseq">
			<xsl:with-param name="s" select="s:Seq5"/>
		</xsl:call-template></span><br/><br/>
	<span class="snpObserved"><xsl:value-of select="s:Observed"/></span><br/><br/>
	<span class="snpSeq"><xsl:call-template name="printseq">
			<xsl:with-param name="s" select="s:Seq3"/>
		</xsl:call-template></span>
	</dd>
</xsl:template>


<xsl:template match="s:Assembly">

 <xsl:variable name="genomeBuild" select="@genomeBuild"/>
 <xsl:variable name="groupLabel" select="@groupLabel"/>
 <xsl:for-each select="s:Component[@chromosome]">
  <xsl:variable name="chromosome" select="@chromosome"/>
  <xsl:for-each select="s:MapLoc[@physMapInt and @leftContigNeighborPos and @rightContigNeighborPos and  @orient]">
    <xsl:variable name="physMapInt" select="@physMapInt"/>
    <xsl:variable name="len" select="number(@rightContigNeighborPos)  - number(@leftContigNeighborPos) -1"/>
    
    <xsl:variable name="chromStart">
    	<xsl:choose>
    		<xsl:when test="$len=0">
    			<xsl:value-of select="number(@physMapInt)+1"/>
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:value-of select="number(@physMapInt)"/>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="chromEnd" select="$chromStart + $len"/>
    <xsl:text>(</xsl:text>
    <xsl:value-of select="$genomeBuild"/>
    <xsl:text>) </xsl:text>
    <xsl:value-of select="concat('chr',$chromosome)"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$chromStart"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$chromEnd"/>
   <xsl:text> </xsl:text>
    <xsl:choose>
		<xsl:when test="@orient='forward'">
			<xsl:text>&#8594;</xsl:text>
		</xsl:when>
		<xsl:when test="@orient='reverse'">
			<xsl:text>&#8592;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="@orient"/>
		</xsl:otherwise>
	</xsl:choose>

    <br/>
  </xsl:for-each>
 </xsl:for-each>

</xsl:template>


<xsl:template name="printseq">
<xsl:param name="s"/>
<xsl:choose>
	<xsl:when test="string-length($s)&gt;60">
		<xsl:value-of select="substring($s,1,60)"/><br/>
		<xsl:call-template name="printseq">
			<xsl:with-param name="s" select="substring($s,60)"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$s"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


</xsl:stylesheet>
