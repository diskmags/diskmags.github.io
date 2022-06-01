<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">

	<xsl:output encoding="UTF-8" indent="no" method="html" standalone="yes" xml:space="default"/>

	<xsl:include href="htmlTemplates.xsl"/>

	<xsl:template match="/">
		<!-- alle Dokumente aus dem TEI-Ordner -->
		<xsl:for-each select="collection('../tei/?select=*.xml')">
			<!-- Dateiname aus dem Pfad ableiten -->
			<xsl:variable name="filename" select="tokenize(base-uri(), '/')[last()]"/>
			<!-- Dateien ausschließen, deren Name mit "_" beginnt -->
			<xsl:if test="not(starts-with($filename, '_'))">
				<!-- HTML-Dokument aufbauen, Speicherort im HTML-Ordner, BOM setzen -->
				<xsl:result-document byte-order-mark="yes"
					href="../{substring-before($filename,'.')}.html">
					<html>
						<!-- HTML-Header -->
						<head>
							<title>
								<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
							</title>
							<xsl:call-template name="htmlMeta"/>
						</head>
						<!-- HTML-Body -->
						<body>
							<!-- HTML-Menü -->
							<nav>
								<a href="md_87-11.html">edition</a>
								<xsl:text> | </xsl:text>
								<a href="app.html">appendix</a>
								<xsl:text> | </xsl:text>
								<a href="about.html">about</a>
							</nav>
							<xsl:apply-templates select="TEI/text/front"/>
							<xsl:apply-templates select="TEI/text/body"/>
							<xsl:apply-templates select="TEI/text/back"/>
							<!-- HTML-Menü -->
							<nav>
								<xsl:text>xml source: </xsl:text>
								<a href="{concat('tei/', $filename)}" target="_blank">
									<xsl:value-of select="$filename"/>
								</a>
							</nav>
						</body>
					</html>
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- CONCEPTIONAL ITEMS, division layer -->

	<!-- TEI front -->
	<xsl:template match="TEI/text/front">
		<!-- HTML-Seitenkopf -->
		<header data-tei="front">
			<xsl:apply-templates/>
		</header>
	</xsl:template>

	<!-- TEI body -->
	<xsl:template match="TEI/text/body">
		<!-- HTML-Seitentext -->
		<article data-tei="body">
			<xsl:apply-templates/>
		</article>
	</xsl:template>

	<!-- TEI back -->
	<xsl:template match="TEI/text/back">
		<!-- HTML-Seitenfuß -->
		<footer data-tei="back">
			<xsl:apply-templates/>
			<!-- noch: Quellenangaben -->
			<!-- noch: Zitationsvorschlag -->
			<!-- noch: Lizenz -->
		</footer>
	</xsl:template>

	<!-- TEI division -->
	<xsl:template match="TEI/text//div">
		<div class="div{count(ancestor::div)+1}" data-tei="div">
			<xsl:apply-templates select="@xml:id | node()"/>
		</div>
	</xsl:template>

	<!-- TEI division ids -->
	<xsl:template match="TEI/text//div/@xml:id">
		<xsl:attribute name="id" select="."/>
	</xsl:template>


	<!-- CONCEPTIONAL ITEMS, block layer -->

	<!-- TEI header -->
	<xsl:template match="TEI/text//head[@type]">
		<!-- type can be h1 or h2 -->
		<!-- TODO: check this by Schematron -->
		<xsl:element name="{@type}">
			<xsl:attribute name="data-tei" select="'head'"/>
			<xsl:apply-templates select="@rend | node()"/>
		</xsl:element>
	</xsl:template>

	<!-- TEI header -->
	<xsl:template match="TEI/text//head[not(@type)]">
		<!-- heading without type becomes h3 -->
		<h3 data-tei="head">
			<xsl:apply-templates select="@rend | node()"/>
		</h3>
	</xsl:template>

	<!-- TEI paragraph -->
	<xsl:template match="TEI/text//p">
		<p data-tei="p">
			<xsl:apply-templates select="@rend | node()"/>
		</p>
	</xsl:template>

	<!-- TEI anonymous block -->
	<!-- implies: ab[rend~='preformatted'] -->
	<!-- implies: ab[rend~='twoColumns'] -->
	<xsl:template match="TEI/text//ab">
		<p data-tei="ab">
			<xsl:apply-templates select="@rend | node()"/>
		</p>
	</xsl:template>

	<!-- TEI forme work -->
	<xsl:template match="TEI/text//fw"/>

	<!-- TEI figure -->
	<xsl:template match="TEI/text//figure">
		<!-- container for images and caption -->
		<figure data-tei="figure">
			<xsl:apply-templates/>
		</figure>
	</xsl:template>

	<!-- TEI graphic -->
	<xsl:template match="TEI/text//figure/graphic">
		<img alt="{../desc/text()}" data-tei="graphic" src="images/{@url}"/>
	</xsl:template>

	<!-- TEI desc -->
	<!-- just in case -->
	<xsl:template match="TEI/text//figure/desc">
		<figcaption data-tei="desc">
			<xsl:apply-templates/>
		</figcaption>
	</xsl:template>


	<!-- CONCEPTIONAL ITEMS, inline layer -->

	<!-- TEI highlight -->
	<xsl:template match="TEI/text//hi">
		<span data-tei="hi">
			<xsl:apply-templates select="@rend | node()"/>
		</span>
	</xsl:template>

	<!-- TEI span -->
	<xsl:template match="TEI/text//span">
		<span data-tei="span">
			<xsl:apply-templates select="@rend | node()"/>
		</span>
	</xsl:template>

	<!-- TEI rendition -->
	<xsl:template match="TEI/text//@rend">
		<!-- insert rend directly into css class -->
		<xsl:attribute name="class" select="."/>
	</xsl:template>

	<!-- TEI reference -->
	<xsl:template match="TEI/text//ref[@target]">
		<!-- create hyperlink -->
		<a data-tei="ref" href="{@target}">
			<xsl:if test="substring(@target, 1, 4) = 'http'">
				<xsl:attribute name="target" select="'_blank'"/>
				<xsl:text>↗</xsl:text>
			</xsl:if>
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<!-- TOPOGRAPHIC ITEMS, generic -->

	<!-- TEI page beginning, in paragraph -->
	<xsl:template match="TEI/text//p//pb">
		<!-- insert a space if first lb on page is 'word breaking' -->
		<xsl:if test="following::lb[1]/@break = 'yes' or not(following::lb[1]/@break)">
			<xsl:text> </xsl:text>
		</xsl:if>
		<!-- insert a mark for the pb -->
		<span class="editorialMark" data-tei="pb">
			<xsl:text>|</xsl:text>
			<!-- insert page number to appear in the margin -->
			<span class="leftMargin" data-tei="@n">
				<xsl:value-of select="@n"/>
			</span>
		</span>
	</xsl:template>

	<!-- TEI page beginning, outside of paragraph -->
	<xsl:template match="TEI/text//div/pb">
		<!-- no mark or extra space required -->
		<!-- insert page number to appear in the margin -->
		<span class="editorialMark" data-tei="pb">
			<span class="leftMargin" data-tei="@n">
				<xsl:value-of select="@n"/>
			</span>
		</span>
	</xsl:template>

	<!-- TEI column beginning -->
	<!-- do not render cb -->
	<xsl:template match="TEI/text//cb"/>

	<!-- TEI line beginning -->
	<xsl:template match="TEI/text//lb[not(@break) or @break = 'yes']">
		<!-- put space if lb is 'word breaking' -->
		<xsl:text> </xsl:text>
	</xsl:template>

	<!-- TEI line beginning, in preserveSpace environment -->
	<!-- prioritized over generic lb -->
	<xsl:template match="TEI/text//p[contains(@rend, 'preserveLines')]//lb" priority="+1">
		<!-- put line break, except for first lb -->
		<xsl:if test="current() >> ancestor::p/lb[1]">
			<br/>
		</xsl:if>
	</xsl:template>

	<!-- TEI line beginning, inside of preformatted environment -->
	<!-- prioritized over generic lb -->
	<xsl:template match="TEI/text//ab[contains(@rend, 'preformatted')]//lb" priority="+1">
		<!-- put line break, except for first lb -->
		<xsl:if test="current() >> ancestor::ab/lb[1]">
			<br/>
		</xsl:if>
	</xsl:template>

	<!-- TEI punctuation character, breaking hyphen -->
	<!-- implies: pc[@type='nbr']/text() is always rendered -->
	<xsl:template match="TEI/text//pc[@type = 'br']"/>

	<!-- TEI span, horizontal ruler as box drawing -->
	<!-- prioritized over generic span -->
	<xsl:template match="span[@ana = '#hr']" priority="+1"/>

	<!-- TEI span, underlining as box drawing -->
	<!-- prioritized over newline template (no \n to be expected here) -->
	<xsl:template match="span[@ana = '#u']/text()" priority="+1">
		<!-- put spaces instead of underline box characters -->
		<xsl:for-each select="1 to string-length(.)">
			<xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:template>

	<!-- TEI space -->
	<xsl:template match="TEI/text//space[@dim = 'vertical']"/>

	<!-- EDITORIAL ITEMS -->

	<!-- TEI choice -->
	<!-- not yet used -->
	<!--<xsl:template match="TEI/text//choice">
		<span data-tei="choice">
			<span class="editorialMark">[</span>
			<xsl:apply-templates select="orig | sic"/>
			<span class="editorialMark">|</span>
			<xsl:apply-templates select="reg | corr"/>
			<span class="editorialMark">]</span>
		</span>
	</xsl:template>-->

	<!-- TEI sic -->
	<!-- not yet used -->
	<!--<xsl:template match="TEI/text/body//sic">
		<span data-tei="sic" title="original text">
			<xsl:apply-templates/>
		</span>
	</xsl:template>-->

	<!-- TEI corr -->
	<!-- not yet used -->
	<!--<xsl:template match="TEI/text//corr">
		<span data-tei="corr" title="corrected text">
			<xsl:apply-templates/>
		</span>
	</xsl:template>-->

	<!-- TEI surplus -->
	<xsl:template match="TEI/text//surplus">
		<span data-tei="surplus" title="surplus text">
			<!-- editorial mark before -->
			<span class="editorialMark">[</span>
			<!-- original text outside of spans -->
			<xsl:apply-templates/>
			<!-- editorial mark after -->
			<span class="editorialMark">]</span>
		</span>
	</xsl:template>

	<!-- TEI supplied -->
	<xsl:template match="TEI/text//supplied">
		<span data-tei="supplied" title="supplied text">
			<span class="editorialText">
				<!-- supplied text inside of span -->
				<xsl:apply-templates/>
			</span>
		</span>
	</xsl:template>

	<!-- TEI term -->
	<xsl:template match="TEI/text//term[@target]">
		<!-- insert a mark in the right margin -->
		<span class="editorialMark rightMargin">
			<!-- teardrop-spoked asterisk -->
			<xsl:text>✻</xsl:text>
		</span>
		<span class="term" data-tei="term">
			<xsl:apply-templates/>
			<xsl:apply-templates mode="note" select="id(substring(@target, 2))"/>
		</span>
	</xsl:template>

	<!-- TEI note -->
	<!-- skip by default -->
	<xsl:template match="TEI/text//note"/>

	<!-- parse only in "note" mode -->
	<xsl:template match="TEI/text//note" mode="note">
		<span class="note" data-tei="note">
			<xsl:apply-templates/>
			<xsl:apply-templates select="@resp"/>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//note/@resp">
		<xsl:text> </xsl:text>
		<i data-tei="@resp">
			<xsl:value-of select="."/>
		</i>
	</xsl:template>


	<!-- SEMANTIC ITEMS -->

	<!-- TEI code -->
	<!-- presented inline -->
	<xsl:template match="TEI/text//code">
		<span class="code" data-tei="code" title="code">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<!-- presented as a text block, but semantically within a paragraph -->
	<xsl:template match="TEI/text//code[@rend = 'block']" priority="+1">
		<span class="code block" data-tei="code" title="code">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- TEI name -->
	<xsl:template match="TEI/text//name">
		<a data-tei="name" title="name">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TEI organization name -->
	<xsl:template match="TEI/text//orgName">
		<a data-tei="orgName" title="orgName">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TEI person name -->
	<xsl:template match="TEI/text//persName">
		<a data-tei="persName" title="persName">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TEI title -->
	<xsl:template match="TEI/text//title">
		<a data-tei="title" title="title">
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<!-- LISTS -->

	<xsl:template match="TEI/text//list[@type] | listPerson | listBibl[@type] | listOrg">
		<ul>
			<xsl:apply-templates mode="list"/>
		</ul>
	</xsl:template>

	<xsl:template match="TEI/text//(list[@type] | listBibl[@type] | listOrg | listPerson)/head"
		mode="list" priority="+1">
		<h3>
			<xsl:apply-templates mode="list"/>
		</h3>
	</xsl:template>

	<xsl:template match="TEI/text//(list[@type] | listBibl[@type] | listOrg | listPerson)/*"
		mode="list">
		<li>
			<b>
				<xsl:apply-templates select="(name | title | orgName | persName)[1]"/>
			</b>
			<xsl:for-each select="(name | title | orgName | persName)[position() > 1]">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates/>
			</xsl:for-each>
			<xsl:for-each select="desc | note">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates/>
			</xsl:for-each>
			<xsl:for-each
				select="document('../tei/md_87-11.xml')//*[substring(@ref, 2) = current()/@xml:id]">
				<xsl:text> </xsl:text>
				<a>
					<xsl:value-of select="substring(preceding::pb[1]/@xml:id, 3)"/>
				</a>
			</xsl:for-each>
		</li>
	</xsl:template>

	<xsl:template match="TEI/text//listBibl[not(@type)]">
		<ul class="bibliography">
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="TEI/text//listBibl[not(@type)]/bibl">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!-- WHITESPACE -->

	<!-- whitespace in newline -->
	<!-- do not render -->
	<xsl:template match="TEI/text//text()">
		<xsl:analyze-string regex="\n" select=".">
			<xsl:matching-substring/>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!-- whitespace in TEI choice -->
	<!-- not yet used -->
	<!--<xsl:template match="TEI/text//choice/text()"/>-->

</xsl:stylesheet>
