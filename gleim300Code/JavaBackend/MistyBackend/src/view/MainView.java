package view;

import controller.XmlReaderWriter;
import model.GleimMenu;

import javax.swing.*;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreePath;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

public class MainView extends JFrame{
    public JPanel panel1;
    private JTree tree1;
    private JScrollBar sbTreeV;
    private JTextField tfName;
    private JTextArea taVoiceCommand;
    private JTextField tfSerialCommand;
    private JTextField tfAudio;
    private JButton button1;
    private JTextArea taReturnCommand;
    private JScrollBar sbVoiceCommands;
    private JScrollBar sbReturnCommandsV;
    private JButton addSubmenuButton;
    private JButton removeSubmenuButton;
    private JButton saveButton;
    private JLabel nameLabel;
    private JLabel voiceCommandLabel;
    private JLabel serialCommandLabel;
    private JLabel audioLabel;
    private JLabel returnCommandLabel;
    private JButton openFileButton;
    private JButton saveValuesButton;
    private JButton newFileButton;
    private JScrollBar sbTreeH;
    private JScrollBar sbReturnCommandsH;

    private GleimMenu selectedMenu;
    private XmlReaderWriter xmlReaderWriter;
    private GleimMenu topLevelMenu;
    private String xmlFilePath = "GleimMenuStructure.xml";
    private int selectedRow;
    private TreePath selectedPath;
    private boolean[] expandedRowArray;

    public MainView() {
        xmlReaderWriter = new XmlReaderWriter(xmlFilePath);
        this.setContentPane(panel1);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.pack();
        this.setVisible(true);
        this.setLocationRelativeTo(null);
        this.setTitle("Misty Backend");

        button1.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                JFileChooser fileChooser = new JFileChooser();
                int result = fileChooser.showOpenDialog(null);
                if (result == JFileChooser.APPROVE_OPTION) {
                    String path = fileChooser.getSelectedFile().getPath();
                    selectedMenu.setAudioFilePath(path);
                    tfAudio.setText(path);
                }
            }
        });
        removeSubmenuButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if(selectedMenu == null) return;
                GleimMenu parentMenu = (GleimMenu) selectedMenu.getParent();
                if(parentMenu == null) return;
                System.out.println(parentMenu.getName());
                new removeMenuDialog(parentMenu, selectedMenu, (DefaultTreeModel) tree1.getModel());
            }
        });
        addSubmenuButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if(selectedMenu == null) return;
                new addMenuDialog(selectedMenu, (DefaultTreeModel) tree1.getModel());
            }
        });
        saveButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if(selectedMenu == null) return;
                saveValues();
                File file = xmlReaderWriter.createXML(topLevelMenu);

                //open file after writing
                if(!Desktop.isDesktopSupported()){
                    System.out.println("Desktop is not supported");
                    return;
                }
                Desktop desktop = Desktop.getDesktop();
                if( file.exists()) {
                    try {
                        desktop.open(file);
                    } catch (IOException e1) {
                        e1.printStackTrace();
                    }
                }
            }
        });
        saveValuesButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                if(selectedMenu == null) return;
                saveValues();
            }
        });
        newFileButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                //hab ich wohl vergessen zu implementieren
            }
        });
        openFileButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                JFileChooser fileChooser = new JFileChooser();
                int result = fileChooser.showOpenDialog(null);
                if (result == JFileChooser.APPROVE_OPTION) {
                    String path = fileChooser.getSelectedFile().getPath();
                    setTree1(new XmlReaderWriter(path).readXML(new File(path)));
                }

             //   repaint();
            }
        });
    }

    private void createUIComponents() {
        tree1 = new JTree(new GleimMenu("topLevel"));
        tree1.addTreeSelectionListener(new TreeSelectionListener() {
            @Override
            public void valueChanged(TreeSelectionEvent e) {
                selectedMenu = (GleimMenu) e.getPath().getLastPathComponent();
                //   getExpandedRows();
                tfName.setText(selectedMenu.getName());
                tfAudio.setText(selectedMenu.getAudioFilePath());
                tfSerialCommand.setText(selectedMenu.getSerialCommand());

                taVoiceCommand.setText("");
                for(String vcommand : selectedMenu.getVoiceCommandList()) {
                    taVoiceCommand.append(vcommand + "\n");
                }

                taReturnCommand.setText("");
                for (String rcommand : selectedMenu.getReturnCommandList()){
                    taReturnCommand.append(rcommand + "\n");
                }
            }
        });
    }

    private void saveValues() {
        selectedMenu.setName(tfName.getText());
        selectedMenu.setAudioFilePath(tfAudio.getText());
        selectedMenu.setSerialCommand(tfSerialCommand.getText());

        String[] voiceCommands = taVoiceCommand.getText().split("\n");
        ArrayList<String> voiceCommandList = new ArrayList<>();
        for (String command : voiceCommands){
            System.out.println("Voice Command: "+command);
            voiceCommandList.add(command);
        }
        selectedMenu.setVoiceCommandList(voiceCommandList);

        String[] returnCommands = taReturnCommand.getText().split("\n");
        ArrayList<String> returnCommandList = new ArrayList<>();
        for (String command : returnCommands){
            returnCommandList.add(command);
        }
        selectedMenu.setReturnCommandList(returnCommandList);
        DefaultTreeModel model = (DefaultTreeModel) tree1.getModel();
        model.reload();
    }

    private void setTree1(GleimMenu gleimMenu){
        topLevelMenu = gleimMenu;
        DefaultTreeModel model = (DefaultTreeModel) tree1.getModel();
        model.setRoot(topLevelMenu);
        model.reload();
    }

    private void getExpandedRows() {
     //   expandedRowArray = new boolean[tree1.cou()];
        for (int t = 0; t < expandedRowArray.length; t++){
           expandedRowArray[t] =  tree1.isExpanded(t);
        }
    }

    private void expandRows(){
        for(int t = 0; t < expandedRowArray.length; t++){
            if(expandedRowArray[t]) tree1.expandRow(t);
        }
    }


}
