package controller;

import model.GleimMenu;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

public class XmlReaderWriter {

    private DocumentBuilderFactory factory;
    private DocumentBuilder builder;
    private Document document;
    private String documentPath;

    /**
     * http://www.mkyong.com/java/how-to-create-xml-file-in-java-dom/
     * @param documentPath String
     */
    public XmlReaderWriter(String documentPath){
        factory = DocumentBuilderFactory.newInstance();
        this.documentPath=documentPath;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public File createXML(GleimMenu gleimMenu){
        document = builder.newDocument();
        Element mainRootElement = document.createElement("MenuStructure");
        document.appendChild(mainRootElement);
        appendMenu(gleimMenu, mainRootElement);

        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        try {
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes"); //make it pretty
            DOMSource source = new DOMSource(document);
            File file = new File(documentPath);
            StreamResult result = new StreamResult(file);
            transformer.transform(source, result);
            System.out.println("File saved!");
            return file;
        } catch (TransformerConfigurationException e) {
            e.printStackTrace();
        } catch (TransformerException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void appendMenu(GleimMenu gleimMenu, Element parentElement){
        Element menuElement = document.createElement("GleimMenu");
        //name
        menuElement.setAttribute("Name", gleimMenu.getName());

        //voice commands
        Element commandListElement = document.createElement("VoiceCommandList");
        for (String command : gleimMenu.getVoiceCommandList()){
            Element commandElement = document.createElement("VoiceCommand");
            commandElement.appendChild(document.createTextNode(command));
            commandListElement.appendChild(commandElement);
        }
        menuElement.appendChild(commandListElement);

        //serial command
        Element serialCommandElement = document.createElement("SerialCommand");
        serialCommandElement.appendChild(document.createTextNode(gleimMenu.getSerialCommand()));
        menuElement.appendChild(serialCommandElement);

        //audio file Path
        Element audioPathElement = document.createElement("AudioPath");
        audioPathElement.appendChild(document.createTextNode(gleimMenu.getAudioFilePath()));
        menuElement.appendChild(audioPathElement);

        //return commands
        Element returnCommandListElement = document.createElement("ReturnCommandList");
        for (String command : gleimMenu.getReturnCommandList()){
            Element commandElement = document.createElement("ReturnCommand");
            commandElement.appendChild(document.createTextNode(command));
            returnCommandListElement.appendChild(commandElement);
        }
        menuElement.appendChild(returnCommandListElement);

        //SubMenuElements
        Element subMenuListElement = document.createElement("SubMenuList");
        for(GleimMenu subMenuElement : gleimMenu.getSubMenuList()){
            appendMenu(subMenuElement, subMenuListElement); //recursive
        }
        menuElement.appendChild(subMenuListElement);

        //append to parent Element
        parentElement.appendChild(menuElement);
    }

    private GleimMenu readMenu(Node node, GleimMenu gleimMenu){

        //name
        gleimMenu.setName(node.getAttributes().getNamedItem("Name").getTextContent());

        NodeList childNotes = node.getChildNodes();
        for(int i = 0; i<childNotes.getLength(); i++){
            Node childNode = childNotes.item(i);

            //voice command list
            if(childNode.getNodeName().equals("VoiceCommandList")){
                NodeList voiceCommandNodes = childNode.getChildNodes();
                for(int j = 0; j < voiceCommandNodes.getLength(); j++){
                    Node voiceCommandNode = voiceCommandNodes.item(j);
                    if(voiceCommandNode.getNodeName().equals("VoiceCommand")){
                        gleimMenu.addVoiceCommand(voiceCommandNode.getTextContent());
                    }
                }
            }

            //serial command
            if(childNode.getNodeName().equals("SerialCommand")){
                gleimMenu.setSerialCommand(childNode.getTextContent());
            }

            //audio path
            if(childNode.getNodeName().equals("AudioPath")){
                gleimMenu.setAudioFilePath(childNode.getTextContent());
            }

            //return command list
            if(childNode.getNodeName().equals("ReturnCommandList")){
                NodeList returnCommandNodes = childNode.getChildNodes();
                for(int j = 0; j < returnCommandNodes.getLength(); j++){
                    Node returnCommandNode = returnCommandNodes.item(j);
                    if(returnCommandNode.getNodeName().equals("ReturnCommand")){
                        gleimMenu.addReturnCommand(returnCommandNode.getTextContent());
                    }
                }
            }

            //Sub menu List
            if(childNode.getNodeName().equals("SubMenuList")){
                NodeList subMenuNodes = childNode.getChildNodes();
                for(int j = 0; j < subMenuNodes.getLength(); j++){
                    Node subMenuNode = subMenuNodes.item(j);
                    if(subMenuNode.getNodeName().equals("GleimMenu")){
                        GleimMenu subMenu = new GleimMenu(null);
                        gleimMenu.addSubMenu(readMenu(subMenuNode, subMenu)); //recursive
                    }
                }
            }
        }
        return gleimMenu;
    }

    /**
     * liest xml mit X-Path ein.
     */
    public GleimMenu readXML(File inputFile) {

        GleimMenu topLevelMenu = new GleimMenu(null);
        try {
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();

            Document doc = dBuilder.parse(inputFile);
            doc.getDocumentElement().normalize();

            XPath xPath = XPathFactory.newInstance().newXPath();

            String expression = "/MenuStructure/GleimMenu";
            NodeList nodeList = (NodeList) xPath.compile(expression).evaluate(doc, XPathConstants.NODESET);
            if(nodeList.getLength() == 1) topLevelMenu = readMenu(nodeList.item(0), topLevelMenu);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return topLevelMenu;
    }

}
