/**
 *
 * LocalWikiGene
 * 
 * Author:
 * 		Pierre Lindenbaum PhD
 * Mail:
 *		plindenbaum@yahoo.fr
 * WWW:
 * 		http://plindenbaum.blogspot.com
 */
package org.lindenb.localgenemw;

import java.io.BufferedReader;
import java.io.Console;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.Attribute;
import javax.xml.stream.events.XMLEvent;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.PostMethod;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
/**

CD8B    CD8b molecule
CD8BP    CD8b molecule pseudogene
CD9    CD9 molecule
CD14    CD14 molecule
CD19    CD19 molecule
MS4A1    membrane-spanning 4-domains, subfamily A, member 1
MS4A3    membrane-spanning 4-domains, subfamily A, member 3 (hematopoietic cell-specific)
CD22    CD22 molecule
CD24    CD24 molecule

*/


/**
 *
 * LocalWikiGene
 *
 */
public class LocalWikiGene
    {
    /** logger */
    private static Logger LOG=Logger.getLogger(LocalWikiGene.class.getName());
    /** Apche Http Client */
    private HttpClient client=new HttpClient();
    /** mediawiki login */
    private String mwLogin=null;
    /** mediawiki password */
    private String mwPassword=null;
    /** path to gene2xml executable  */
    private String pathToGene2XML="gene2xml";
    /** genes as ASN.1 */
    private String geneAsAsn="gene.ags";
    /** MW API URL */
    private String mwApiUrl="http://localhost/api.php";
    /** prefix of the Template: pages */
    private String templatePrefix="Gene";
    /** shall we create an article if it doesn't exist ? */
    private boolean createArticle=false;
    /** namespace for articles */
    private String articleNamespace="";
    /** XML document builder */
    private DocumentBuilder domBuilder=null;
    /** XPATH processor */
    private XPath xpath=null;
    /** exclude list */
    private Set<String> excludeList=null;
    /** include list */
    private Set<String> includeList=null;
    /** alternate XSLT stylesheet */
    private File altXsltStylesheet=null;
    
    /** constructor */
    private LocalWikiGene()
    throws Exception
	    {
	    //build the XML builder
	    DocumentBuilderFactory fact=DocumentBuilderFactory.newInstance();
	    fact.setNamespaceAware(false);
	    fact.setCoalescing(true);
	    fact.setIgnoringComments(true);
	    fact.setIgnoringElementContentWhitespace(true);
	    this.domBuilder=fact.newDocumentBuilder();
	    //build the xpath processor
	    XPathFactory xf=XPathFactory.newInstance();
	    this.xpath=xf.newXPath();
	    }
    
    /** get credentials from mediawiki */
    private void login() throws IOException,SAXException,XPathExpressionException
        {
        LOG.info("logging as "+this.mwLogin);
        String mwToken=null;
        while(true)
            {
            PostMethod postMethod=new PostMethod(this.mwApiUrl);
            postMethod.addParameter("action", "login");
            postMethod.addParameter("lgname", this.mwLogin);
            postMethod.addParameter("lgpassword",  this.mwPassword);
            postMethod.addParameter("format", "xml");
            if(mwToken!=null)
                {
                LOG.info("using mwToken "+mwToken);
                postMethod.addParameter("lgtoken",mwToken);
                }
            this.client.executeMethod(postMethod);
            InputStream in=postMethod.getResponseBodyAsStream();
            Document dom= this.domBuilder.parse(in);
            postMethod.releaseConnection();
            in.close();
            
            mwToken = this.xpath.evaluate("/api/login/@token",dom);
            String result= this.xpath.evaluate("/api/login/@result",dom);
            if(result==null) result="";
            LOG.info("server says "+result);
            if(result.equals("Success"))
            	{
            	break;
            	}
            else if(result.equals("NeedToken"))
            	{
            	continue;
            	}
            else
                {
                throw new RuntimeException("Cannot log as "+
                		this.mwLogin+
                		" result:"+result
                		);
                }
            }
        }

    /** log off from mediawiki */
    private void logout() throws IOException,SAXException
        {
        PostMethod postMethod=new PostMethod(this.mwApiUrl);
        postMethod.addParameter("action", "logout");
        postMethod.addParameter("format", "xml");
        this.client.executeMethod(postMethod);
        InputStream in=postMethod.getResponseBodyAsStream();
        this.domBuilder.parse(in);
        in.close();
        postMethod.releaseConnection();
        LOG.info("logged out");
        }

    /** parse Gene doc */
    private void parseDoc(
            XMLEventReader reader,
            Document dom,
            Element root)
        throws Exception
        {
        while(reader.hasNext())
            {
            XMLEvent evt=reader.nextEvent();
            if(evt.isEndElement())
                {
                return;
                }
            else if(evt.isStartElement())
                {
                Element node=dom.createElement(evt.asStartElement().getName().getLocalPart());
                root.appendChild(node);
                Iterator<?> iter=evt.asStartElement().getAttributes();
                while(iter.hasNext())
                    {
                    Attribute att=(Attribute)iter.next();
                    node.setAttribute(att.getName().getLocalPart(), att.getValue());
                    }
                parseDoc(reader,dom,node);
                }
            else if(evt.isCharacters())
                {
                root.appendChild(dom.createTextNode(evt.asCharacters().getData()));
                }
            }
        }


    
    /** let's do the job */
    private void run()
        throws Exception
        {
        login();

        // create XSLT factory and et XSLT stylesheet
        InputStream xslIn=null;
        if(this.altXsltStylesheet!=null)
        	{
        	LOG.info("reading alt stylesheet "+this.altXsltStylesheet);
        	xslIn=new FileInputStream(this.altXsltStylesheet);
        	}
        else
        	{
        	LOG.info("reading /META-INF/gene2wiki.xsl");
        	xslIn=LocalWikiGene.class.getResourceAsStream("/META-INF/gene2wiki.xsl");
        	}
        if(xslIn==null) throw new IOException("cannot get xsl");

        TransformerFactory trFactory=TransformerFactory.newInstance();
        Templates templates=trFactory.newTemplates(new StreamSource(xslIn));
        xslIn.close();
        Transformer transform=templates.newTransformer();
        transform.setParameter("templatePrefix",this.templatePrefix);
        transform.setParameter("ns",this.articleNamespace);

        //create xml stream factory
        XMLInputFactory xmlInputFactory = XMLInputFactory.newInstance();
        xmlInputFactory.setProperty(XMLInputFactory.IS_NAMESPACE_AWARE, Boolean.FALSE);
        xmlInputFactory.setProperty(XMLInputFactory.IS_COALESCING, Boolean.TRUE);
        xmlInputFactory.setProperty(XMLInputFactory.IS_REPLACING_ENTITY_REFERENCES, Boolean.TRUE);
        

      
        //create XPATH expressions
        XPathExpression idExpr=xpath.compile("/Entrezgene/Entrezgene_track-info/Gene-track/Gene-track_geneid");
        XPathExpression locusExpr=xpath.compile("/Entrezgene/Entrezgene_gene/Gene-ref/Gene-ref_locus");
        XPathExpression descExpr=xpath.compile("/Entrezgene/Entrezgene_gene/Gene-ref/Gene-ref_desc");
        XPathExpression refGeneExpr=xpath.compile("/Entrezgene/Entrezgene_locus/Gene-commentary/Gene-commentary_products/Gene-commentary[Gene-commentary_heading='Reference']/Gene-commentary_accession");
        XPathExpression ensemblExpr=xpath.compile("/Entrezgene/Entrezgene_gene/Gene-ref/Gene-ref_db/Dbtag[Dbtag_db='Ensembl']/Dbtag_tag/Object-id/Object-id_str");

        //call NCBI gene2xml
        Process proc=Runtime.getRuntime().exec(new String[]{
        		this.pathToGene2XML,
                "-b",//asn1 is binary
                "-i",this.geneAsAsn //ASN.1 input
                });
        //read input as XML stream
        InputStream in=proc.getInputStream();
        XMLEventReader reader= xmlInputFactory.createXMLEventReader(in);
        while(reader.hasNext())
            {
            XMLEvent evt=reader.nextEvent();
            if(!evt.isStartElement()) continue;
            //it is a gene
            if(!evt.asStartElement().getName().getLocalPart().equals("Entrezgene")) continue;
            Document dom=this.domBuilder.newDocument();
            Element root=dom.createElement("Entrezgene");
            dom.appendChild(root);
            //get the whole record as DOM
            parseDoc(reader,dom,root);
            
            //get locus name with xpath
            String locus=(String)locusExpr.evaluate(root, XPathConstants.STRING);
            //should we ignore it ?
            if( (this.includeList!=null && !this.includeList.contains(locus)) ||
            	(this.excludeList!=null && this.excludeList.contains(locus))		
            	)
            	{
            	LOG.info("ignore "+locus);
            	continue;
            	}
            String ensembl=(String)ensemblExpr.evaluate(root, XPathConstants.STRING);
            String refGene=(String)refGeneExpr.evaluate(root, XPathConstants.STRING);

            
            LOG.info(
        		"ID:"+idExpr.evaluate(root, XPathConstants.STRING)+
        		"\t"+locus+
        		"\t"+descExpr.evaluate(root, XPathConstants.STRING)+
        		"\t"+ensembl+
        		"\t"+refGene
        		);
            
            if(ensembl.length()==0 && refGene.length()==0)
                {
                System.err.println("??BOUM");
                }
            StringWriter sw=new StringWriter();
            transform.transform(new DOMSource(dom), new StreamResult(sw));
            
            //cleanup
            System.gc();

            PostMethod postMethod=new PostMethod(this.mwApiUrl);
            postMethod.addParameter("action", "query");
            postMethod.addParameter("intoken", "edit");
            postMethod.addParameter("titles", "Template:"+this.templatePrefix+locus);
            postMethod.addParameter("prop", "info");
            postMethod.addParameter("format", "xml");


            this.client.executeMethod(postMethod);
            InputStream inMW=postMethod.getResponseBodyAsStream();
            Document result= this.domBuilder.parse(inMW);
            inMW.close();
            postMethod.releaseConnection();
            
            NodeList pages=(NodeList)this.xpath.evaluate("/api/query/pages/page",result,XPathConstants.NODESET);
            Element page=(Element)pages.item(0);

            String starttimestamp=page.getAttribute("starttimestamp");
            String edittoken=page.getAttribute("edittoken");
           
            this.postNewArticle(
            		"Template:"+this.templatePrefix+locus,
            		"bot creating template for Gene "+locus,
            		edittoken,
            		starttimestamp,
            		sw.toString()
            		);

            //shall we create the page ?
            if(this.createArticle)
            	 {
            	 //check article doesn't exists
            	 postMethod=new PostMethod(this.mwApiUrl);
                 postMethod.addParameter("action", "query");
                 postMethod.addParameter("intoken", "edit");
                 postMethod.addParameter("titles",
                		 (articleNamespace.isEmpty()?"":articleNamespace+":")
                		 +locus);
                 postMethod.addParameter("prop", "info");
                 postMethod.addParameter("format", "xml");
                 this.client.executeMethod(postMethod);
                 inMW=postMethod.getResponseBodyAsStream();
                 result = this.domBuilder.parse(inMW);
                 inMW.close();
                 postMethod.releaseConnection();
                 pages=(NodeList)this.xpath.evaluate("/api/query/pages/page",result,XPathConstants.NODESET);
                 page=(Element)pages.item(0);
                 if(page.getAttributeNode("missing")==null)
                	 {
                	 starttimestamp=page.getAttribute("starttimestamp");
                     edittoken=page.getAttribute("edittoken");
                	 
                	 //ok, page does not exist, create it
                	 String article="{{"+this.templatePrefix+locus+"}}";
                	 
                     this.postNewArticle(
                     		(articleNamespace.isEmpty()?"":articleNamespace+":")+locus,
                     		"bot creating article for Gene "+locus,
                     		edittoken,
                     		starttimestamp,
                     		article
                     		);
                	 }
            	 }
            }
        reader.close();
        in.close();
        proc.destroy();

        logout();
        }
    
    /** post new article to mediawiki */
    private void postNewArticle(
    	String title,
    	String summary,
    	String editToken,
    	String starttimestamp,
    	String text
    	) throws IOException,SAXException,XPathExpressionException
    	{
    	PostMethod postMethod=new PostMethod(this.mwApiUrl);
        postMethod.addParameter("action", "edit");
        postMethod.addParameter("format", "xml");
        postMethod.addParameter("title", title);
        postMethod.addParameter("summary", summary);
        postMethod.addParameter("text", text);
        postMethod.addParameter("bot", "true");
        postMethod.addParameter("token", editToken);
        postMethod.addParameter("starttimestamp", starttimestamp);
        postMethod.addParameter("md5",DigestUtils.md5Hex(text));
        this.client.executeMethod(postMethod);
        InputStream inMW=postMethod.getResponseBodyAsStream();
        Document dom = this.domBuilder.parse(inMW);
        inMW.close();
        postMethod.releaseConnection();
        String result= this.xpath.evaluate("/api/edit/@result", dom);
        if(result==null) result="";
        if(!result.equals("Success"))
        	{
        	throw new IOException("Inserting "+title+" failed . result was "+result);
        	}
    	}
    
    private static Set<String> readLocusList(String filename)
    	throws IOException
    	{
    	Set<String> set=new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);
    	BufferedReader in=new BufferedReader(new FileReader(filename));
    	String line;
    	while((line=in.readLine())!=null)
    		{
    		line=line.trim();
    		if(line.isEmpty()) continue;
     		set.add(line);
    		}
    	in.close();
    	return set;
    	}
    
    /** main */
	public static void main(String[] args) {
		try
			{
			String excludeFile=null;
			String includeFile=null;
			LOG.setLevel(Level.OFF);
			LocalWikiGene app= new LocalWikiGene();
			int optind=0;
			while(optind< args.length)
				{
				if(args[optind].equals("-h") ||
				   args[optind].equals("-help") ||
				   args[optind].equals("--help"))
					{
					System.err.println("Pierre Lindenbaum PhD; 2010");
					System.err.println("Options:");
					System.err.println(" -h help; This screen.");
					System.err.println(" -u <user.login>");
					System.err.println(" -p <user.password> (or asked later on command line)");
					System.err.println(" -a <api.url> e.g. http://en.wikipedia.org/w/api.php");
					System.err.println(" -g <path to gene2xml> default: "+app.pathToGene2XML);
					System.err.println(" -s <path to gene.ags> default: "+app.geneAsAsn);
					System.err.println(" -ns <article namespace> default:none (Main namespace)");
					System.err.println(" -t <template prefix> default: "+app.templatePrefix );
					System.err.println(" -c create article if it doesn't exist default: "+app.createArticle );
					System.err.println(" -X <file> reads a file containing a list of locuses to be excluded. (optional)");
					System.err.println(" -i <file> reads a file containing the only list of accepted locuses. (optional)");
					System.err.println(" -y <file> reads an alternat xslt stylesheet. (optional)");
					System.err.println(" -debug turns debug on. (optional)");
					return;
					}
				else if(args[optind].equals("-debug"))
					{
					LOG.setLevel(Level.ALL);
					}
				else if(args[optind].equals("-u"))
					{
					app.mwLogin = args[++optind];
					}
				else if(args[optind].equals("-p"))
					{
					app.mwPassword = args[++optind];
					}
				else if(args[optind].equals("-a"))
					{
					app.mwApiUrl = args[++optind];
					}
				else if(args[optind].equals("-g"))
					{
					app.pathToGene2XML=args[++optind];
					}
				else if(args[optind].equals("-s"))
					{
					app.geneAsAsn=args[++optind];
					}
				else if(args[optind].equals("-ns"))
					{
					app.articleNamespace=args[++optind];
					}
				else if(args[optind].equals("-t"))
					{
					app.templatePrefix=args[++optind];
					}
				else if(args[optind].equals("-c"))
					{
					app.createArticle=true;
					}
				else if(args[optind].equals("-X"))
					{
					excludeFile=args[++optind];
					}
				else if(args[optind].equals("-i"))
					{
					includeFile=args[++optind];
					}
				else if(args[optind].equals("-y"))
					{
					app.altXsltStylesheet=new File(args[++optind]);
					}
				else if(args[optind].equals("--"))
					{
					optind++;
					break;
					}
				else if(args[optind].startsWith("-"))
					{
					System.err.println("Unknown option "+args[optind]);
					return;
					}
				else 
					{
					break;
					}
				++optind;
				}
			if(optind!=args.length)
				{
				System.err.println("Illegal number of arguments.");
				return;
				}
			
			if(excludeFile!=null && includeFile!=null)
				{
				System.err.println("Cannot use both include and exclude lists.");
				return;
				}
			else if(excludeFile!=null)
				{
				app.excludeList= readLocusList(excludeFile);
				}
			else if(includeFile!=null)
				{
				app.includeList= readLocusList(includeFile);
				}
			
			
			if(app.mwLogin==null || app.mwLogin.isEmpty())
				{
				System.err.println("empty login.");
				return;
				}
			
			if(app.mwPassword==null)
                {
                Console console=System.console();
                if(console==null)
                        {
                        System.err.println("Undefined Password.");
                        return;
                        }
                 char pass[] = console.readPassword("Mediawiki Password ? : ");
                 if(pass==null || pass.length==0)
                        {
                        System.err.println("Cannot read Password.");
                        return;
                        }
                app.mwPassword=new String(pass);
                }
			
			app.run();
			LOG.info("Done.");
			} 
		catch(Throwable err)
			{
			err.printStackTrace();
			}
		}
    }