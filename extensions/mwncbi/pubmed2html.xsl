<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	version='1.0'
	>

<xsl:output method='html' />

<xsl:template match="/">
<div>
<xsl:apply-templates select="PubmedArticleSet|Error"/>
</div>
</xsl:template>

<xsl:template match="Error">
An error occured. <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="PubmedArticleSet">
<xsl:apply-templates select="PubmedArticle"/>
</xsl:template>

<xsl:template match="PubmedArticle">
<dl>
<xsl:apply-templates select="MedlineCitation"/>
<xsl:apply-templates select="ArticleIdList"/>
</dl>
</xsl:template>


<xsl:template match="PMID">
<dt>PMID</dt>
<dd><xsl:element name="a">
	<xsl:attribute name="target"><xsl:value-of select="concat('pubmed:',.)"/></xsl:attribute>
	<xsl:attribute name="href"><xsl:value-of select="concat('http://www.ncbi.nlm.nih.gov/pubmed/',.)"/></xsl:attribute>
	<xsl:value-of select="."/>
	</xsl:element></dd>
</xsl:template>
	
<xsl:template match="MedlineCitation">
	<xsl:apply-templates select="PMID"/>
	<xsl:apply-templates select="Article"/>
</xsl:template>

<xsl:template match="Journal">
	<u><xsl:value-of select="Title"/></u>
</xsl:template>



<xsl:template match="Article">
	<xsl:apply-templates select="ArticleTitle"/>
	<xsl:apply-templates select="Journal/JournalIssue/PubDate"/>
	<dt>Reference</dt><dd>
	<xsl:apply-templates select="Journal"/> <xsl:text> </xsl:text>
	<xsl:apply-templates select="Journal/JournalIssue"/> <xsl:text> </xsl:text>
	<xsl:apply-templates select="Pagination/MedlinePgn"/></dd>
	<xsl:apply-templates select="AuthorList"/>
	
	<xsl:apply-templates select="Abstract/AbstractText"/>
</xsl:template>

<xsl:template match="AbstractText">
	<dt>Abstract</dt>
	<dd><span class="pubmedAbstract"><xsl:value-of select="."/></span></dd>
</xsl:template>

<xsl:template match="ArticleTitle">
	<dt>Title</dt>
	<dd><xsl:value-of select="."/></dd>
</xsl:template>


<xsl:template match="JournalIssue">
<xsl:if test="Volume"><b>vol.<xsl:value-of select="Volume"/></b><xsl:text> </xsl:text></xsl:if>
<xsl:if test="Issue"><i><xsl:text>(</xsl:text><xsl:value-of select="Issue"/><xsl:text>)</xsl:text></i><xsl:text> </xsl:text></xsl:if>
</xsl:template>

<xsl:template match="MedlinePgn">
	<xsl:value-of select="concat('pp.',.,' ')"/>
</xsl:template>



<xsl:template match="AuthorList">
<dt>Authors</dt>
<dd>
<xsl:for-each select="Author">
<xsl:choose>
<xsl:when test="position()=1">
</xsl:when>
<xsl:when test="position()=last()">
<xsl:text> and </xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>, </xsl:text>
</xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="."/>
</xsl:for-each>
</dd>
</xsl:template>

<xsl:template match="Author">
<xsl:variable name="firstName"><xsl:choose>
<xsl:when test="ForeName"><xsl:value-of select="ForeName"/></xsl:when>
<xsl:when test="FirstName"><xsl:value-of select="FirstName"/></xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose></xsl:variable>


<xsl:variable name="lastName"><xsl:choose>
<xsl:when test="LastName"><xsl:value-of select="concat(' ',LastName)"/></xsl:when>
<xsl:when test="Initials"><xsl:value-of select="concat(' ',Initials)"/></xsl:when>
<xsl:when test="CollectiveName"> Collective Work</xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose></xsl:variable>

<xsl:value-of select="$firstName"/>
<xsl:value-of select="$lastName"/>
</xsl:template>



<xsl:template match="ArticleIdList">
	<xsl:value-of select="ArticleId"/>
</xsl:template>


<xsl:template match="ArticleId">
	<xsl:choose>
		<xsl:when test="@IdType=&apos;doi&apos;">
			<dt>doi</dt>
			<dd><xsl:element name="a">
				<xsl:attribute name="href">
				  <xsl:value-of select="concat('http://dx.doi.org/10.1038/',.)"/>
				</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element></dd>
		</xsl:when>
	</xsl:choose>
</xsl:template>


<xsl:template match="PubDate">
<dt>Date</dt>
<dd>
<xsl:if test="Year">
	<xsl:value-of select="Year"/>
	<xsl:if test="Month">
		<xsl:text> </xsl:text>
		<xsl:value-of select="Month"/>
		<xsl:if test="Day">
			<xsl:text> </xsl:text>
			<xsl:value-of select="Day"/>
		</xsl:if>
	</xsl:if>
</xsl:if>
</dd>
</xsl:template>



</xsl:stylesheet>
