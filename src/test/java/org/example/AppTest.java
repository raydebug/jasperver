package org.example;

import junit.framework .Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import net.sf.jasperreports.engine.export.JRCsvExporter;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.engine.export.JRXlsExporter;
import org.apache.poi.hpsf.SummaryInformation;

/**
 * Unit test for simple App.
 */
public class AppTest 
    extends TestCase
{
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public AppTest( String testName )
    {
        super( testName );
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite()
    {
        return new TestSuite( AppTest.class );
    }

    /**
     * Rigourous Test :-)
     */
    public void testApp()
    {
        new SummaryInformation();
        new JRPdfExporter();
        new JRCsvExporter();
        new JRXlsExporter();
        assertTrue( true );
    }
}
