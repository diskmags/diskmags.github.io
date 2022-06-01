<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

	<sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>

	<sch:let name="appendix" value="document('../app.xml')"/>

	<sch:pattern id="ref">
		<sch:rule context="tei:text//tei:ref">
			<sch:assert test="@target">@target fehlt</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern id="noteRef">
		<sch:rule context="tei:text//tei:note[@resp]">
			<sch:assert test="@xml:id">@xml:id fehlt</sch:assert>
			<sch:assert test="//(tei:ref|tei:term)[substring(@target,2)=current()/@xml:id]">keine Bezugnahme gefunden</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern id="titleRef">
		<sch:rule context="tei:text//tei:title">
			<sch:assert test="@ref">@ref fehlt</sch:assert>
			<sch:assert test="$appendix//id(substring(current()/@ref,2))">@ref '<sch:value-of select="substring(current()/@ref,2)"/>' nicht gefunden</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern id="nameRef">
		<sch:rule context="tei:text//tei:name">
			<sch:assert test="@ref">@ref fehlt</sch:assert>
			<sch:assert test="$appendix//id(substring(current()/@ref,2))">@ref '<sch:value-of select="substring(current()/@ref,2)"/>' nicht gefunden</sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern id="orgRef">
		<sch:rule context="tei:text//tei:orgName">
			<sch:assert test="@ref">@ref fehlt</sch:assert>
			<sch:assert test="$appendix//id(substring(current()/@ref,2))">@ref '<sch:value-of select="substring(current()/@ref,2)"/>' nicht gefunden</sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern id="persRef">
		<sch:rule context="tei:text//tei:persName">
			<sch:assert test="@ref">@ref fehlt</sch:assert>
			<sch:assert test="$appendix//id(substring(current()/@ref,2))">@ref '<sch:value-of select="substring(current()/@ref,2)"/>' nicht gefunden</sch:assert>
		</sch:rule>
	</sch:pattern>
	
</sch:schema>
