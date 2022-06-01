<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">

	<xsl:output encoding="UTF-8" indent="no" xml:space="default" method="xhtml" standalone="yes"/>

	<xsl:include href="htmlTemplates.xsl"/>

	<xsl:template match="/">
		<!-- alle Dokumente aus dem TEI-Ordner -->
		<xsl:for-each select="collection('../tei/?select=*.xml')">
			<!-- Dateiname aus dem Pfad ableiten -->
			<xsl:variable name="filename" select="tokenize(base-uri(), '/')[last()]"/>
			<!--<xsl:value-of select="$filename"/>-->
			<!-- Dateien ausschließen, deren Name mit "_" beginnt -->
			<xsl:if test="not(starts-with($filename, '_'))">
				<!-- HTML-Dokument aufbauen, Speicherort im HTML-Ordner, BOM setzen -->
				<xsl:result-document byte-order-mark="yes"
					href="../html/{substring-before($filename,'.')}.html">
					<html>
						<!-- HTML-Header -->
						<head>
							<title>
								<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
							</title>
							<xsl:call-template name="htmlMeta"></xsl:call-template>
						</head>
						<!-- HTML-Body -->
						<body>
							<!-- HTML-Menü -->
							<aside>
								<nav>
									<h4><a href=".">GAME ON</a></h4>
									<h4>Spezialseiten</h4>
									<ul>
										<xsl:for-each select="/TEI/text/div">
											<li><a href="#{@xml:id}"><xsl:value-of select="@xml:id"/></a></li>
										</xsl:for-each>
									</ul>
								</nav>
							</aside>
							<!-- Kopfbereich -->
							<header>
								<h1>
									<xsl:value-of
										select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
								</h1>
							</header>
							<!-- Textbereich -->
							<article id="document">
								<xsl:apply-templates select="TEI/text"/>
							</article>
							<!-- Fußbereich -->
							<footer id="bibl">
								<xsl:text>Quelle: </xsl:text>
								<xsl:apply-templates select="/TEI/teiHeader/fileDesc/sourceDesc"/>
								<!-- noch: Zitationsvorschlag -->
								<!-- noch: Lizenz -->
							</footer>
						</body>
					</html>
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- page structure -->

	<xsl:template match="TEI/text/front">
		<div class="teiFront {@rend}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="TEI/text/body">
		<div class="teiBody {@rend}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!-- document appearance -->

	<xsl:template match="TEI/text//head">
		<h2 class="{@rend}" data-tei="head">
			<xsl:apply-templates/>
		</h2>
	</xsl:template>

	<xsl:template match="TEI/text//p">
		<p class="{@rend}" data-tei="p">
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	
	<xsl:template match="TEI/text//ab[@type='boxDrawing']">
		<span class="{@rend}" data-tei="ab">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//graphic">
		<img class="{graphic}" data-tei="graphic" src="../images/{@src}" title="Abbildung: {@title}"/>
	</xsl:template>

	<xsl:template match="TEI/text//g">
		<span data-tei="g" title="Sonderzeichen: {@desc}">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//hi">
		<xsl:choose>
			<xsl:when test="contains(@rend, 'widespace')">
				<!-- Sonderbehandlung von Sperrungen -->
				<xsl:variable name="charBefore"
					select="substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]))"/>
				<xsl:variable name="charAfter"
					select="substring(following-sibling::text()[1], 1, 1)"/>
				<span data-tei="hi">
					<xsl:attribute name="class">
						<xsl:value-of select="@rend"/>
						<xsl:text> </xsl:text>
						<!-- widespaceBefore bei vorausgehendem Spatium -->
						<xsl:if test="contains(' ', $charBefore)">
							<xsl:text> widespaceBefore</xsl:text>
						</xsl:if>
						<!-- noWidespaceAfter bei anschließenden (kleinen) Satzzeichen -->
						<xsl:if test="contains(',.“', $charAfter)">
							<xsl:text> noWidespaceAfter</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<span class="{@rend}" data-tei="hi">
					<xsl:apply-templates/>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- editorial elements -->

	<xsl:template match="TEI/text//choice">
		<span class="editorial choice">[</span>
		<xsl:apply-templates select="orig | sic"/>
		<span class="editorial choice">|</span>
		<xsl:apply-templates select="reg | corr"/>
		<span class="editorial choice">]</span>
	</xsl:template>

	<xsl:template match="TEI/text//choice/text()"/>

	<xsl:template match="TEI/text/body//choice/sic">
		<span title="editorial sic">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//choice/corr">
		<span class="editorial corr" title="corr">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//gap">
		<span class="editorial gap" title="Auslassung">
			<xsl:text>…</xsl:text>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//surplus">
		<span class="surplus" title="überflüssiger Text">
			<span class="editorial">[</span>
			<xsl:apply-templates/>
			<span class="editorial">]</span>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//supplied">
		<span class="editorial supplied" title="fehlender Text">
			<xsl:text>[</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>]</xsl:text>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//pb | TEI/text//cb">
		<xsl:variable as="element()" name="type">
			<xsl:choose>
				<xsl:when test="name() = 'pb'">
					<foo symbol="/" type="Seite"/>
				</xsl:when>
				<xsl:when test="name() = 'cb'">
					<foo symbol="|" type="Spalte"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<span class="editorial fontReset {name(.)}" title="{$type/@type}nanfang">
			<xsl:if test="@type = 'skipped'">
				<xsl:text>… </xsl:text>
			</xsl:if>
			<xsl:if test="@break = 'no'">
				<xsl:text>-</xsl:text>
			</xsl:if>
			<xsl:value-of select="$type/@symbol"/>
			<xsl:choose>
				<xsl:when test="@facs">
					<a href="{id(substring(@facs,2))/@url}">
						<xsl:apply-templates select="@n"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@n"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$type/@symbol"/>
			<xsl:if test="not(@break) or @break = 'yes'">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="@type = 'skipped'">
				<xsl:text> …</xsl:text>
			</xsl:if>
		</span>
	</xsl:template>

	<!-- Zeilenumbruch mit Wortunterbrechung -->
	<!-- default -->
	<xsl:template match="TEI/text//lb[not(@break)]">
		<xsl:text> </xsl:text>
	</xsl:template>

	<!-- Bindestriche entfernen -->
	<xsl:template match="TEI/text//pc[@type='br']"/>
	
	<!-- Zeilenumbrüche überall rausfiltern -->
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="\n">
			<xsl:matching-substring/>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="TEI/text//note">
		<span class="note">
			<sup class="noteAnchor">
				<xsl:number level="any"/>
			</sup>
			<span class="noteContent">
				<span class="noteContentAnchor">
					<xsl:number level="any"/>)</span>
				<span class="noteContentText">
					<xsl:apply-templates/>
				</span>
			</span>
		</span>
	</xsl:template>


	<!-- semantic elements -->

	<xsl:template match="TEI/text//date">
		<a class="{string-join(('date',@rend),' ')}" title="Datum">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="TEI/text//rs[@type = 'event']">
		<span class="semantic rs" title="Aufführung">
			<a class="event" href="{concat('event?id=', @ref)}">
				<!-- HALFWIDTH LEFT CORNER BRACKET (U+FF62) -->
				<xsl:text>｢</xsl:text>
			</a>
			<xsl:apply-templates/>
			<a class="event" href="{concat('event?id=', @ref)}">
				<!-- HALFWIDTH RIGHT CORNER BRACKET (U+FF63) -->
				<xsl:text>｣</xsl:text>
			</a>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//persName">
		<a data-tei="persName" title="Person">
			<xsl:attribute name="href" select="concat('person?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="TEI/text//placeName">
		<a data-tei="placeName" title="Ort">
			<xsl:attribute name="href" select="concat('place?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="TEI/text//title">
		<a class="semantic title" title="Werk der Musik">
			<xsl:attribute name="href" select="concat('title?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="TEI/text//orgName">
		<a class="semantic orgName" title="Ort">
			<xsl:attribute name="href" select="concat('org?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<xsl:template match="TEI/text//ref">
		<a class="semantic ref" title="Textbezug">
			<xsl:attribute name="href" select="concat('document?fn=', @href)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<!-- bibliographic elements -->

	<xsl:template match="sourceDesc/bibl">
		<xsl:apply-templates/>
		<xsl:text>.</xsl:text>
	</xsl:template>

	<xsl:template match="sourceDesc//orgName[@role = 'publisher']">
		<xsl:value-of select="@ref"/>
	</xsl:template>

	<xsl:template match="sourceDesc//placeName">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="@ref"/>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="sourceDesc//date[@when-iso]">
		<xsl:value-of select="@when-iso"/>
	</xsl:template>
	
	<xsl:template match="sourceDesc//series">
		<xsl:value-of select="."/>
	</xsl:template>

</xsl:stylesheet>
