<?xml version='1.0'  encoding="ISO-8859-1" ?>
<xsl:stylesheet
	xmlns:h="http://www.w3.org/1999/xhtml"
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
<xsl:apply-templates select="Entrezgene-Set|Error"/>
</div>
</xsl:template>

<xsl:template match="Error">
An error occured. <xsl:value-of select="."/>
</xsl:template>


<xsl:template match="Entrezgene-Set">
<div>
<xsl:apply-templates select="Entrezgene"/>
</div>
</xsl:template>

<xsl:template match="Entrezgene">
<dl>
<xsl:apply-templates select="Entrezgene_gene"/>
<xsl:apply-templates select="Entrezgene_source"/>
<xsl:apply-templates select="Entrezgene_summary"/>
</dl>
</xsl:template>

<xsl:template match="Entrezgene_gene">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="Gene-ref_locus">
<dt>Official Symbol</dt>
<dd>
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="concat('http://www.ncbi.nlm.nih.gov/gene/',../../../Entrezgene_track-info/Gene-track/Gene-track_geneid)"/></xsl:attribute>
<xsl:value-of select="."/>
</xsl:element>
</dd>
</xsl:template>

<xsl:template match="Gene-ref_desc">
<dt>Full Name</dt>
<dd><xsl:value-of select="."/></dd>
</xsl:template>

<xsl:template match="Gene-ref_maploc">
<dt>Location</dt>
<dd><xsl:value-of select="."/></dd>
</xsl:template>

<xsl:template match="Gene-ref_syn">
<dt>Other Names</dt>
<dd><xsl:apply-templates select="Gene-ref_syn_E"/></dd>
</xsl:template>

<xsl:template match="Gene-ref_syn_E">
<span><xsl:value-of select="."/></span>
<xsl:text>; </xsl:text>
</xsl:template>

<xsl:template match="Gene-ref_db">
<dt>See related</dt>
<dd><xsl:apply-templates select="Dbtag"/></dd>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='HGNC']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_id">
<xsl:text> </xsl:text>
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="concat('http://www.genenames.org/data/hgnc_data.php?hgnc_id=',.)"/></xsl:attribute>
<xsl:value-of select="concat('HGNC:',.)"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='Ensembl']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_str">
<xsl:text> </xsl:text>
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="concat('http://www.ensembl.org/Homo_sapiens/geneview?gene=',.)"/></xsl:attribute>
<xsl:value-of select="concat('Ensembl:',.)"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='HPRD']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_str">
<xsl:text> </xsl:text>
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="concat('http://www.hprd.org/protein/',.)"/></xsl:attribute>
<xsl:value-of select="concat('HPRD:',.)"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='MIM']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_id">
<xsl:text> </xsl:text>
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="concat('http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=',.)"/></xsl:attribute>
<xsl:value-of select="concat('MIM:',.)"/>
</xsl:element>
</xsl:for-each>
</xsl:template>

<xsl:template match="Dbtag">
<xsl:variable name="dbtag_db" select="Dbtag_db"/>
<xsl:for-each select="Dbtag_tag/Object-id/*">
<xsl:text> </xsl:text>
<xsl:value-of select="concat($dbtag_db,':',.)"/>
</xsl:for-each>
</xsl:template>

<xsl:template match="Entrezgene_source">
<xsl:apply-templates select="//Org-ref_taxname"/>
<xsl:apply-templates select="//OrgName_lineage"/>
</xsl:template>


<xsl:template match="Org-ref_taxname">
<dt>Organism</dt>
<dd><xsl:value-of select="."/></dd>
</xsl:template>

<xsl:template match="OrgName_lineage">
<dt>Lineage</dt>
<dd><xsl:value-of select="."/></dd>
</xsl:template>

<xsl:template match="Entrezgene_summary">
<dt>Summary</dt>
<dd><xsl:value-of select="."/></dd>
</xsl:template>



</xsl:stylesheet>
