<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes" />
<xsl:param name="foamVersion"/>

<!-- How a test section is parsed -->
<xsl:template name="Sections" match="Section">
<xsl:for-each select="Section">
    <xsl:choose>
        <xsl:when test="starts-with(@name, 'Given:')">
        <tr style="border-collapse: collapse; background-color: #0016ae;">
            <td colspan="100%" style="padding: 2px;"></td>
        </tr>
        </xsl:when>
    </xsl:choose>
    <tr>
        <td><xsl:value-of select="@name"/></td>
        <td style="white-space: pre-line">
            <xsl:choose>
                <xsl:when test="Info">
                <xsl:for-each select="Info">
                <!-- Let's not repeat what's obvious -->
                <xsl:if test="not(preceding-sibling::Info[text() = current()/text()])">
                <xsl:value-of select="."/>
                </xsl:if>
                </xsl:for-each>
                </xsl:when>
        </xsl:choose>
        </td>
        <td><xsl:value-of select="OverallResults/@successes"/></td>
        <td><xsl:value-of select="OverallResults/@failures"/></td>
        <td><xsl:value-of select="OverallResults/@expectedFailures"/></td>
        <td>
            <xsl:for-each select="Expression">
                <p><code><xsl:value-of select="Original"/></code></p>
            </xsl:for-each>
        </td>
        <td>
            <xsl:for-each select="Expression">
                <xsl:value-of select="@type"/>
            </xsl:for-each>
        </td>
        <td><xsl:value-of select="OverallResults/@durationInSeconds"/></td>
        </tr>
        <xsl:choose>
            <xsl:when test="BenchmarkResults">
            <tr stype="padding: 0;">
            <td></td>
            <td colspan="5" style="margin: 0;padding: 1px;">
            <table class="bordered" style="border-collapse: collapse; padding: 0; margin: 0;">
                <tr>
                    <th rowspan="2">Benchmark name</th>
                    <th rowspan="2">Samples</th>
                    <th rowspan="2">Duration (ms)</th>
                    <th rowspan="2">Stats</th>
                    <th colspan="4">Data</th>
                </tr>
                <tr>
                    <th style="white-space: pre-line">Value/
                    Variance (ms)
                    </th>
                    <th style="white-space: pre-line">LowerBound/
                    LowMild-LowSevere (ms)
                    </th>
                    <th style="white-space: pre-line">UpperBound/
                    HighMild-HighSevere (ms)
                    </th>
                    <th>CI</th>
                </tr>

                <xsl:for-each select="BenchmarkResults">
                <xsl:call-template name="Benchmark"> </xsl:call-template>
                </xsl:for-each>
            </table>
            </td>
            </tr>
            </xsl:when>
        </xsl:choose>
<xsl:choose>
<xsl:when test="Section">
    <xsl:call-template name="Sections"></xsl:call-template>
</xsl:when>
</xsl:choose>
                </xsl:for-each>
</xsl:template>

<xsl:template name="Benchmark" match="BenchmarkResults">
                <tr>
                        <td rowspan="3"><xsl:value-of select="@name"/></td>
                        <td rowspan="3"><xsl:value-of select="@samples"/></td>
                        <td rowspan="3"><xsl:value-of select="format-number(@estimatedDuration * 1e-6, '0.######')"/></td>
                        <td>Mean</td>
                        <td><xsl:value-of select="format-number(mean/@value * 1e-6, '0.######')"/></td>
                        <td><xsl:value-of select="format-number(mean/@lowerBound * 1e-6, '0.######')"/></td>
                        <td><xsl:value-of select="format-number(mean/@upperBound * 1e-6, '0.######')"/></td>
                        <td><xsl:value-of select="mean/@ci"/></td>
                </tr>
                <tr>
                        <td>Std Deviation</td>
                        <td><xsl:value-of select="format-number(standardDeviation/@value * 1e-6, '0.######')"/></td>
                        <td><xsl:value-of select="format-number(standardDeviation/@lowerBound * 1e-6, '0.######')"/></td>
                        <td><xsl:value-of select="format-number(standardDeviation/@upperBound * 1e-6, '0.######')"/></td>
                        <td><xsl:value-of select="standardDeviation/@ci"/></td>
                </tr>
                <tr>
                        <td>Outliers</td>
                        <td><xsl:value-of select="outliers/@variance"/></td>
                        <td><xsl:value-of select="outliers/@lowMild"/> -
                        <xsl:value-of select="outliers/@lowSevere"/>
                        </td>
                        <td><xsl:value-of select="outliers/@highMild"/> -
                        <xsl:value-of select="outliers/@highSevere"/>
                        <td></td>
                        </td>
                </tr>
</xsl:template>

<xsl:template match="/" extension-element-prefixes="catch" >
<html>
<head>
    <title>Test Results</title>
    <style type="text/css">
            td#passed {
                    color: green;
                    font-weight: bold;
            }
            td#failed {
                    color: red;
                    font-weight: bold;
            }
            <!-- borrowod from here http://red-team-design.com/practical-css3-tables-with-rounded-corners/ -->
            body {
                    width: 80%;
                    margin: 40px auto;
                    font-family: 'trebuchet MS', 'Lucida sans', Arial;
                    font-size: 14px;
                    color: #444;
            }
            table {
                    *border-collapse: collapse; /* IE7 and lower */
                    border-spacing: 0;
                    width: 100%;
            }
            .bordered {
                    border: solid #ccc 1px;
                    border-top: none;
                    -moz-border-radius: 0;
                    -webkit-border-radius: 0;
                    border-radius: 0;
                    -webkit-box-shadow: 0 1px 1px #ccc; 
                    -moz-box-shadow: 0 1px 1px #ccc; 
                    box-shadow: 0 1px 1px #ccc;         
            }
            .bordered tr:hover {
                    background: #fbf8e9;
                    -o-transition: all 0.1s ease-in-out;
                    -webkit-transition: all 0.1s ease-in-out;
                    -moz-transition: all 0.1s ease-in-out;
                    -ms-transition: all 0.1s ease-in-out;
                    transition: all 0.1s ease-in-out;     
            }    
            .bordered td, .bordered th {
                    border-top: 1px solid #ccc;
                    padding: 10px;
                    text-align: left;    
            }
            .bordered th {
                    /*background-image: -webkit-gradient(linear, left top, left bottom, from(#dce9f9), to(#dce9f9));
                    background-image: -webkit-linear-gradient(top, #ce9f9, #dce9f9);
                    background-image:    -moz-linear-gradient(top, #ce9f9, #dce9f9);
                    background-image:     -ms-linear-gradient(top, #ce9f9, #dce9f9);
                    background-image:      -o-linear-gradient(top, #ce9f9, #dce9f9);
                    background-image:         linear-gradient(top, #ce9f9, #dce9f9);*/
                    background-color: #0016ae;
                    color: white;
                    -webkit-box-shadow: 0 1px 0 rgba(255,255,255,.8) inset; 
                    -moz-box-shadow:0 1px 0 rgba(255,255,255,.8) inset;  
                    box-shadow: 0 1px 0 rgba(255,255,255,.8) inset;        
                    text-shadow: 0 1px 0 rgba(255,255,255,.5); 
            }
            .bordered th:first-child {
                    -moz-border-radius: 0 0 0 0;
                    -webkit-border-radius: 0 0 0 0;
                    border-radius: 0 0 0 0;
            }
            .bordered th:last-child {
                    -moz-border-radius: 0 0 0 0;
                    -webkit-border-radius: 0  0 0 0;
                    border-radius: 0 0 0 0;
            }
            .bordered th:only-child{
                    -moz-border-radius: 0 0 0 0;
                    -webkit-border-radius: 0 0 0 0;
                    border-radius: 0 0 0 0;
            }
            .bordered tr:last-child td:first-child {
                    -moz-border-radius: 0 0 0 0;
                    -webkit-border-radius: 0 0 0 0;
                    border-radius: 0 0 0 0;
            }
            .bordered tr:last-child td:last-child {
                    -moz-border-radius: 0 0 0 0;
                    -webkit-border-radius: 0 0 0 0;
                    border-radius: 0 0 0 0;
            }

    </style>
</head>
<body>
    <xsl:apply-templates/>
</body>
</html>
 
</xsl:template>
 
<!-- File header -->
<xsl:template match="Catch2TestRun">
    <h1>Test Run for <b><xsl:value-of select="@name"/></b>
        library (Catch v<xsl:value-of select="@catch2-version"/>)
        using <xsl:value-of select = "$foamVersion" />
    </h1>
    <h2>Tagged as <xsl:value-of select="@filters"/>,
        total of <b><xsl:value-of select="count(TestCase)"/></b> test cases
    </h2>
    <p>
        <span style="color:green;"><b><xsl:value-of select="OverallResults/@successes"/></b></span>
        expressions are passing and
        <span style="color:red;"><b><xsl:value-of select="OverallResults/@failures"/></b></span>
        expressions failed.
    </p>
    <xsl:apply-templates/>
</xsl:template>
 
<!-- Tests -->
<xsl:template match="TestCase">
    <div>
        <h2 style="vertical-align: middle; display: inline-block; float: left; width: 75%;">
            <xsl:value-of select="@name"/></h2>
        <!-- No sections, No Benchmarks, Put a summary -->
        <xsl:choose>
        <xsl:when test="Expression">
        <table class="bordered">
            <tr>
                <th>Expression</th>
                <th>Successful?</th>
                <th>Type</th>
                <th>Location</th>
            </tr>
            <xsl:for-each select="Expression">
            <tr>
                <td>
                    <p><code><xsl:value-of select="Original"/></code></p>
                </td>
                <td><xsl:value-of select="@success"/></td>
                <td><xsl:value-of select="@type"/></td>
                <td><xsl:value-of select="@filename"/>:<xsl:value-of select="@line"/></td>
            </tr>
            </xsl:for-each>
        </table>
        <xsl:choose>
            <xsl:when test="Info">
            <table class="bordered">
                <tr>
                    <th>
                        Captures
                        <td style="white-space: pre-line">
                            <p><code><xsl:for-each select="Info">
                                        <td>
                                <xsl:if test="not(preceding-sibling::Info[text() = current()/text()])">
                                <xsl:value-of select="."/>
                                </xsl:if>
                        </td>
                            </xsl:for-each></code></p>
                        </td>
                    </th>
                </tr>
            </table>
            </xsl:when>
        </xsl:choose>
        <table class="bordered" style="vertical-align: middle; float: right; width: 25%;">
            <tr>
                <th style="background-image:-moz-linear-gradient(top, red, red);color:white;">
                    <xsl:if test="OverallResult/@success = 'true'">
                        <xsl:attribute name="style">
                            <xsl:text>background-image:-moz-linear-gradient(top, green, green);color:white;</xsl:text>
                        </xsl:attribute>
                        Passing
                    </xsl:if>
                    <xsl:if test="OverallResult/@success = 'false'"> Failing </xsl:if>
                </th>
                <th>Duration <xsl:value-of select="format-number(OverallResult/@durationInSeconds, '0.######')"/> (s)</th>
            </tr>
        </table>
        </xsl:when>
        </xsl:choose>
    </div>
    <table></table>
    <div>
        <xsl:choose>
            <xsl:when test="BenchmarkResults">
            <h3> Test case Benchmarks</h3>
            <table class="bordered">
                <tr>
                    <th rowspan="2">Benchmark name</th>
                    <th rowspan="2">Samples</th>
                    <th rowspan="2">Duration (ms)</th>
                    <th rowspan="2">Stats</th>
                    <th colspan="4">Data</th>
                </tr>
                <tr>
                    <th style="white-space: pre-line">Value/
                    Variance (ns)
                    </th>
                    <th style="white-space: pre-line">LowerBound/
                    LowMild-LowSevere (ns)
                    </th>
                    <th style="white-space: pre-line">UpperBound/
                    HighMild-HighSevere (ns)
                    </th>
                    <th>CI</th>
                </tr>

                <xsl:for-each select="BenchmarkResults">
                    <xsl:call-template name="Benchmark"> </xsl:call-template>
                </xsl:for-each>
            </table>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="Section">
            <h3> Sections for "<xsl:value-of select="@name"/>"</h3>
            <table class="bordered">
                <tr>
                    <th>Section name</th>
                    <th>Captures</th>
                    <th>Successes</th>
                    <th>Failures</th>
                    <th>Expected Failures</th>
                    <th>Expression</th>
                    <th>Type</th>
                    <th>Duration (s)</th>
                </tr>
                <xsl:call-template name="Sections"> </xsl:call-template>
            </table>
            </xsl:when>
        </xsl:choose>
    </div>
 
    <div style="height: 30px;"></div>
</xsl:template>
</xsl:stylesheet>
