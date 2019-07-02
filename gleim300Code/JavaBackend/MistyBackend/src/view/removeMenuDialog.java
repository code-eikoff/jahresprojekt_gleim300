package view;

import model.GleimMenu;

import javax.swing.*;
import javax.swing.tree.DefaultTreeModel;
import java.awt.*;
import java.awt.event.*;

public class removeMenuDialog extends JDialog {
    private JPanel contentPane;
    private JButton buttonOK;
    private JButton buttonCancel;
    private GleimMenu parent;
    private GleimMenu toRemove;
    private DefaultTreeModel model;

    public removeMenuDialog(GleimMenu parent, GleimMenu toRemove, DefaultTreeModel model) {
        pack();
        setVisible(true);
        setLocationRelativeTo(null);
        setContentPane(contentPane);
        setModal(true);
        getRootPane().setDefaultButton(buttonCancel);
        setMinimumSize(new Dimension(300, 100));

        this.parent=parent;
        this.toRemove=toRemove;
        this.model=model;

        buttonOK.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                onOK();
            }
        });

        buttonCancel.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                onCancel();
            }
        });

        // call onCancel() when cross is clicked
        setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                onCancel();
            }
        });

        // call onCancel() on ESCAPE
        contentPane.registerKeyboardAction(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                onCancel();
            }
        }, KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0), JComponent.WHEN_ANCESTOR_OF_FOCUSED_COMPONENT);
    }

    private void onOK() {
        // add your code here
        parent.removeSubMenu(toRemove);
        model.reload();
        dispose();
    }

    private void onCancel() {
        // add your code here if necessary
        dispose();
    }
}
