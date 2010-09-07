<?xml version='1.0'  encoding="ISO-8859-1" ?>
<xsl:stylesheet
    xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
    version='1.0'
    >
<!--
Author:
    Pierre Lindenbaum PhD
Contact:
    http://plindenbaum.blogspot.com
    plindenbaum@yahoo.fr
Motivation:
    transforms ncbi gene to wiki
-->
<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes" />
<xsl:param name="ns"></xsl:param>
<xsl:param name="templatePrefix">Gene</xsl:param>
<xsl:variable name="nsPrefix">
	<xsl:choose>
		<xsl:when test="string-length($ns)&gt;0">
			<xsl:value-of select="concat($ns,':')"/>
		</xsl:when>
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:template match="/">
<xsl:apply-templates/>
</xsl:template>




<xsl:template match="Entrezgene-Set">
<xsl:apply-templates select="Entrezgene"/>
</xsl:template>

<xsl:template match="Entrezgene">
<xsl:variable name="geneId" select="Entrezgene_track-info/Gene-track/Gene-track_geneid"/>
<xsl:variable name="locus" select="Entrezgene_gene/Gene-ref/Gene-ref_locus"/>
<includeonly>
<div style="width: 500px; background-color: lightgray; padding: 10px; margin: 10px; border: 1px solid darkgray; float: right; -moz-box-shadow: 6px 6px 6px gray;box-shadow: 6px 6px 6px gray;">
<dl>
<xsl:call-template name="DT"/>
<xsl:text>NCBI GeneID</xsl:text>
<xsl:call-template name="DD"/><xsl:value-of select="$geneId"/>
<xsl:call-template name="DT"/><xsl:text>Official Symbol</xsl:text>
<xsl:call-template name="DD"/>
<xsl:text>[</xsl:text>
<xsl:value-of select="concat('http://www.ncbi.nlm.nih.gov/gene/',$geneId)"/>
<xsl:text> </xsl:text>
<xsl:value-of select="$locus"/>
<xsl:text>]
</xsl:text>
<xsl:apply-templates select="Entrezgene_gene"/>
<xsl:apply-templates select="Entrezgene_source"/>
</dl>
</div>
<xsl:text>
=</xsl:text>
<xsl:value-of select="$locus"/>
<xsl:text>=
</xsl:text>
<xsl:value-of select="concat('&#8220;',Entrezgene_summary,'&#8221;')"/>
<xsl:text>
</xsl:text>
<xsl:apply-templates select="Entrezgene_comments/Gene-commentary[Gene-commentary_heading='Interactions']" mode="ppi"/>
<xsl:apply-templates select="Entrezgene_properties/Gene-commentary[Gene-commentary_heading='GeneOntology']" mode="go"/>
<xsl:text>
[[Category:Ncbi genes]]</xsl:text>
</includeonly><noinclude>This is a [http://www.mediawiki.org/wiki/Help:Templates template] for the NCBI gene '''<xsl:value-of select="$locus"/>''' ID.<xsl:value-of select="$geneId"/>. To use this template insert <br/><span style="background-color:black; color:white; font-size:150%;"><nowiki>{{<xsl:value-of select="concat($templatePrefix,$locus)"/>}}</nowiki></span><br/> in body of the article.
An article about '''<xsl:value-of select="$locus"/>''' should be located at :[[<xsl:value-of select="concat($nsPrefix,$locus)"/>|<xsl:value-of select="$locus"/>]]

[[Category:Ncbi gene templates]]</noinclude>

</xsl:template>

<xsl:template match="Entrezgene_gene">
<xsl:apply-templates select="Gene-ref"/>
</xsl:template>

<xsl:template match="Gene-ref">
<xsl:apply-templates select="Gene-ref_desc|Gene-ref_maploc|Gene-ref_syn|Gene-ref_db"/>
</xsl:template>

<xsl:template match="Gene-ref_desc">
<xsl:call-template name="DT"/>
<xsl:text>Full Name</xsl:text>
<xsl:call-template name="DD"/>
<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="Gene-ref_maploc">
<xsl:call-template name="DT"/>
<xsl:text>Location</xsl:text>
<xsl:call-template name="DD"/>
<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="Gene-ref_syn">
<xsl:call-template name="DT"/><xsl:text>Other Names</xsl:text>
<xsl:call-template name="DD"/><xsl:for-each select="Gene-ref_syn_E">
<xsl:if test="position()&gt;1">
<xsl:text>, </xsl:text>
</xsl:if>
<xsl:value-of select="."/>
</xsl:for-each>
</xsl:template>


<xsl:template match="Gene-ref_db">
<xsl:call-template name="DT"/>
<xsl:text>Related</xsl:text>
<xsl:call-template name="DD"/><xsl:apply-templates select="Dbtag"/>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='HGNC']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_id">
<xsl:text> [</xsl:text>
<xsl:value-of select="concat('http://www.genenames.org/data/hgnc_data.php?hgnc_id=',.)"/>
<xsl:text> </xsl:text>
<xsl:value-of select="concat('HGNC:',.)"/>
<xsl:text>]</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='Ensembl']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_id">
<xsl:text> [</xsl:text>
<xsl:value-of select="concat('http://www.ensembl.org/Homo_sapiens/geneview?gene=',.)"/>
<xsl:text> </xsl:text>
<xsl:value-of select="concat('Ensembl:',.)"/>
<xsl:text>]</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='HPRD']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_id">
<xsl:text> [</xsl:text>
<xsl:value-of select="concat('http://www.hprd.org/protein/',.)"/>
<xsl:text> </xsl:text>
<xsl:value-of select="concat('HPRD:',.)"/>
<xsl:text>]</xsl:text>
</xsl:for-each>

</xsl:template>

<xsl:template match="Dbtag[Dbtag_db='MIM']">
<xsl:for-each select="Dbtag_tag/Object-id/Object-id_id">
<xsl:text> [</xsl:text>
<xsl:value-of select="concat('http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=',.)"/>
<xsl:text> </xsl:text>
<xsl:value-of select="concat('MIM:',.)"/>
<xsl:text>]</xsl:text>
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
<xsl:apply-templates select="BioSource/BioSource_org/Org-ref"/>
</xsl:template>


<xsl:template match="Org-ref">
<xsl:apply-templates select="Org-ref_taxname"/>
<xsl:apply-templates select="Org-ref_orgname/OrgName/OrgName_lineage"/>
</xsl:template>

<xsl:template match="Org-ref_taxname">
<xsl:call-template name="DT"/><xsl:text>Organism</xsl:text>
<xsl:call-template name="DD"/><xsl:value-of select="."/>
</xsl:template>

<xsl:template match="OrgName_lineage">
<xsl:call-template name="DT"/><xsl:text>Lineage</xsl:text>
<xsl:call-template name="DD"/><xsl:value-of select="."/>
</xsl:template>




<xsl:template match="Gene-commentary" mode="go">
<xsl:for-each select="Gene-commentary_comment/Gene-commentary/Gene-commentary_comment/Gene-commentary/Gene-commentary_source">
<xsl:if test="Other-source/Other-source_src/Dbtag/Dbtag_db='GO'">
<xsl:text>[[Category:</xsl:text>
<xsl:value-of select="Other-source/Other-source_anchor"/>
<xsl:text>]]</xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match="Gene-commentary" mode="ppi">
<xsl:variable name="interactors" select="Gene-commentary_comment//Gene-commentary/Gene-commentary_source/Other-source[Other-source_src/Dbtag/Dbtag_db='GeneID']"/>
<xsl:if test="count($interactors)&gt;0">
<xsl:text>
==Interactions==
</xsl:text>
<xsl:element name="span">
<xsl:if test="count($interactors)&gt;10">
<xsl:attribute name="style">font-size: smaller;</xsl:attribute>
</xsl:if>
<xsl:for-each select="$interactors">
<xsl:sort select="Other-source_anchor"/>
<xsl:choose>
  <xsl:when test="position()=1 and position()=last()"/>
  <xsl:when test="position()=last()">
     <xsl:text> and </xsl:text>
  </xsl:when>
  <xsl:when test="position()=1"/>
  <xsl:otherwise>
  	<xsl:text>, </xsl:text>
  </xsl:otherwise>
</xsl:choose>

<xsl:text>[[</xsl:text>
<xsl:value-of select="concat($nsPrefix,Other-source_anchor)"/>
<xsl:text>|</xsl:text>
<xsl:value-of select="Other-source_anchor"/>
<xsl:text>]]</xsl:text>
</xsl:for-each>
</xsl:element>
</xsl:if>
</xsl:template>


<xsl:template name="DT">
<xsl:text disable-output-escaping="yes">&lt;dt&gt;</xsl:text>
</xsl:template>

<xsl:template name="DD">
<xsl:text disable-output-escaping="yes">&lt;dd&gt;</xsl:text>
</xsl:template>

</xsl:stylesheet>
