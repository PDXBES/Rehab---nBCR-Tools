namespace PipXP
{
    partial class PipXP
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveAsDatabaseToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveAsTextToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadFromDatabaseToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.refreshSourceTablesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.designateSourceTablesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.assignPipeDataToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.editToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.translateEMGAATSPipesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.segmentPipesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.processToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.runPipXPToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.button1 = new System.Windows.Forms.Button();
            this.buttonRunCostEstimator = new System.Windows.Forms.Button();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.editToolStripMenuItem,
            this.processToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(364, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.saveAsDatabaseToolStripMenuItem,
            this.saveAsTextToolStripMenuItem,
            this.loadFromDatabaseToolStripMenuItem,
            this.refreshSourceTablesToolStripMenuItem,
            this.designateSourceTablesToolStripMenuItem,
            this.assignPipeDataToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // saveAsDatabaseToolStripMenuItem
            // 
            this.saveAsDatabaseToolStripMenuItem.Name = "saveAsDatabaseToolStripMenuItem";
            this.saveAsDatabaseToolStripMenuItem.Size = new System.Drawing.Size(198, 22);
            this.saveAsDatabaseToolStripMenuItem.Text = "Save as database...";
            this.saveAsDatabaseToolStripMenuItem.Click += new System.EventHandler(this.saveAsDatabaseToolStripMenuItem_Click);
            // 
            // saveAsTextToolStripMenuItem
            // 
            this.saveAsTextToolStripMenuItem.Name = "saveAsTextToolStripMenuItem";
            this.saveAsTextToolStripMenuItem.Size = new System.Drawing.Size(198, 22);
            this.saveAsTextToolStripMenuItem.Text = "Save as text...";
            // 
            // loadFromDatabaseToolStripMenuItem
            // 
            this.loadFromDatabaseToolStripMenuItem.Name = "loadFromDatabaseToolStripMenuItem";
            this.loadFromDatabaseToolStripMenuItem.Size = new System.Drawing.Size(198, 22);
            this.loadFromDatabaseToolStripMenuItem.Text = "Load from database...";
            this.loadFromDatabaseToolStripMenuItem.Click += new System.EventHandler(this.loadFromDatabaseToolStripMenuItem_Click);
            // 
            // refreshSourceTablesToolStripMenuItem
            // 
            this.refreshSourceTablesToolStripMenuItem.Name = "refreshSourceTablesToolStripMenuItem";
            this.refreshSourceTablesToolStripMenuItem.Size = new System.Drawing.Size(198, 22);
            this.refreshSourceTablesToolStripMenuItem.Text = "Refresh source tables";
            // 
            // designateSourceTablesToolStripMenuItem
            // 
            this.designateSourceTablesToolStripMenuItem.Name = "designateSourceTablesToolStripMenuItem";
            this.designateSourceTablesToolStripMenuItem.Size = new System.Drawing.Size(198, 22);
            this.designateSourceTablesToolStripMenuItem.Text = "Designate source tables";
            this.designateSourceTablesToolStripMenuItem.Click += new System.EventHandler(this.designateSourceTablesToolStripMenuItem_Click);
            // 
            // assignPipeDataToolStripMenuItem
            // 
            this.assignPipeDataToolStripMenuItem.Name = "assignPipeDataToolStripMenuItem";
            this.assignPipeDataToolStripMenuItem.Size = new System.Drawing.Size(198, 22);
            this.assignPipeDataToolStripMenuItem.Text = "Assign pipe data";
            this.assignPipeDataToolStripMenuItem.Click += new System.EventHandler(this.assignPipeDataToolStripMenuItem_Click);
            // 
            // editToolStripMenuItem
            // 
            this.editToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.translateEMGAATSPipesToolStripMenuItem,
            this.segmentPipesToolStripMenuItem});
            this.editToolStripMenuItem.Name = "editToolStripMenuItem";
            this.editToolStripMenuItem.Size = new System.Drawing.Size(39, 20);
            this.editToolStripMenuItem.Text = "Edit";
            // 
            // translateEMGAATSPipesToolStripMenuItem
            // 
            this.translateEMGAATSPipesToolStripMenuItem.Name = "translateEMGAATSPipesToolStripMenuItem";
            this.translateEMGAATSPipesToolStripMenuItem.Size = new System.Drawing.Size(210, 22);
            this.translateEMGAATSPipesToolStripMenuItem.Text = "Translate EMGAATS pipes";
            // 
            // segmentPipesToolStripMenuItem
            // 
            this.segmentPipesToolStripMenuItem.Name = "segmentPipesToolStripMenuItem";
            this.segmentPipesToolStripMenuItem.Size = new System.Drawing.Size(210, 22);
            this.segmentPipesToolStripMenuItem.Text = "Segment pipes";
            // 
            // processToolStripMenuItem
            // 
            this.processToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.runPipXPToolStripMenuItem});
            this.processToolStripMenuItem.Name = "processToolStripMenuItem";
            this.processToolStripMenuItem.Size = new System.Drawing.Size(59, 20);
            this.processToolStripMenuItem.Text = "Process";
            // 
            // runPipXPToolStripMenuItem
            // 
            this.runPipXPToolStripMenuItem.Name = "runPipXPToolStripMenuItem";
            this.runPipXPToolStripMenuItem.Size = new System.Drawing.Size(129, 22);
            this.runPipXPToolStripMenuItem.Text = "Run PipXP";
            this.runPipXPToolStripMenuItem.Click += new System.EventHandler(this.runPipXPToolStripMenuItem_Click);
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(201, 193);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(160, 69);
            this.button1.TabIndex = 2;
            this.button1.Text = "Run PipeXP";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // buttonRunCostEstimator
            // 
            this.buttonRunCostEstimator.Location = new System.Drawing.Point(201, 310);
            this.buttonRunCostEstimator.Name = "buttonRunCostEstimator";
            this.buttonRunCostEstimator.Size = new System.Drawing.Size(160, 69);
            this.buttonRunCostEstimator.TabIndex = 3;
            this.buttonRunCostEstimator.Text = "Run CostEstimator";
            this.buttonRunCostEstimator.UseVisualStyleBackColor = true;
            this.buttonRunCostEstimator.Click += new System.EventHandler(this.buttonRunCostEstimator_Click);
            // 
            // PipXP
            // 
            this.Controls.Add(this.buttonRunCostEstimator);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.menuStrip1);
            this.Name = "PipXP";
            this.Size = new System.Drawing.Size(364, 382);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem saveAsDatabaseToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem saveAsTextToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem loadFromDatabaseToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem refreshSourceTablesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem editToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem translateEMGAATSPipesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem segmentPipesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem processToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem runPipXPToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem designateSourceTablesToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem assignPipeDataToolStripMenuItem;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button buttonRunCostEstimator;

    }
}
