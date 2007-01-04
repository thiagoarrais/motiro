#  Motiro - A project tracking tool
#  Copyright (C) 2006-2007  Thiago Arrais
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

  P1 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060717200939' local_date='Mon Jul 17 17:09:39 BRT 2006' inverted='False' hash='20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'>
	<name>Some refactoring after the mess</name>
</patch>
</changelog>
END

  P2 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060813140540' local_date='Sun Aug 13 11:05:40 BRT 2006' inverted='False' hash='20060813140540-49d33-a640b3999077a8be03d81825ad7d40108c827250.gz'>
        <name>Cheking for ghc --make output</name>
        <comment>
Still need testing on Windows. Much probably there are file system and/or
linebreaking issues.</comment>
</patch>
</changelog>
END

  P3 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060822135332' local_date='Tue Aug 22 10:53:32 Hora oficial do Brasil 2006' inverted='False' hash='20060822135332-47d7b-f311f9b4f4f2d329d8de62efaa09c5d20cf08f8f.gz'>
	<name> </name>
</patch>
</changelog>
END

  P4 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20060717200939' local_date='Mon Jul 17 17:09:39 BRT 2006' inverted='False' hash='20060717200939-49d33-c04fbb63892ae64cd96d1ad8f1ad2dd0a6e8e7da.gz'>
	<name>Some refactoring after the mess</name>
</patch>
<patch author='thiago.arrais@gmail.com' date='20060813140540' local_date='Sun Aug 13 11:05:40 BRT 2006' inverted='False' hash='20060813140540-49d33-a640b3999077a8be03d81825ad7d40108c827250.gz'>
        <name>Cheking for ghc --make output</name>
        <comment>
Still need testing on Windows. Much probably there are file system and/or
linebreaking issues.</comment>
</patch>
</changelog>
END

  P5 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20061120200104' local_date='Mon Nov 20 17:01:04 BRT 2006' inverted='False' hash='20061120200104-49d33-41e1ddac59f9a3cfa80c59492a686ab69ee5cd92.gz'>
	<name>Activated restore defaults button for preference page</name>
</patch>
</changelog>
END
  
  P5DIFF = <<END
Mon Nov 20 17:01:04 BRT 2006  thiago.arrais@gmail.com
  * Activated restore defaults button for preference page
diff -rN -u old-eclipsefp/net.sf.eclipsefp.haskell.ui/src/net/sf/eclipsefp/haskell/ui/preferences/BuildConsolePP.java new-eclipsefp/net.sf.eclipsefp.haskell.ui/src/net/sf/eclipsefp/haskell/ui/preferences/BuildConsolePP.java
--- old-eclipsefp/net.sf.eclipsefp.haskell.ui/src/net/sf/eclipsefp/haskell/ui/preferences/BuildConsolePP.java	2006-12-12 09:38:40.000000000 -0300
+++ new-eclipsefp/net.sf.eclipsefp.haskell.ui/src/net/sf/eclipsefp/haskell/ui/preferences/BuildConsolePP.java	2006-12-12 09:38:40.000000000 -0300
@@ -56,18 +56,36 @@
 		fChkCleanConsole = new Button(composite, SWT.CHECK);
 		fChkCleanConsole.setText("Always clear console before building");
 		
+		createListeners();
+		fillValuesInControls();
+		return composite;
+	}
+
+	private void createListeners() {
 		fChkCleanConsole.addSelectionListener(new SelectionListener() {
 
-			public void widgetDefaultSelected(SelectionEvent e) {}
+			public void widgetDefaultSelected(SelectionEvent e) {
+				//ignore event
+			}
 
 			public void widgetSelected(SelectionEvent e) {
 				fStore.setValue(CLEAR_BUILD_CONSOLE, fChkCleanConsole.getSelection());
 			}
 			
 		});
-		
+	}
+
+	private void fillValuesInControls() {
 		fChkCleanConsole.setSelection(fStore.getBoolean(CLEAR_BUILD_CONSOLE));
-		return composite;
+	}
+
+	
+	@Override
+	protected void performDefaults() {
+		super.performDefaults();
+		
+		fStore.setToDefault(CLEAR_BUILD_CONSOLE);
+		fillValuesInControls();
 	}
 
 	@Override

END
  
  P6 = <<END
<changelog>
<patch author='thiago.arrais@gmail.com' date='20061120181253' local_date='Mon Nov 20 15:12:53 BRT 2006' inverted='False' hash='20061120181253-49d33-fd91e402f9667bc07e0e329831afcbde49b4fae8.gz'>
	<name>Started build console preference page with clean before build option</name>
</patch>
</changelog>
END

  P6DIFF = <<END
Mon Nov 20 15:12:53 BRT 2006  thiago.arrais@gmail.com
  * Started build console preference page with clean before build option
diff -rN -u old-eclipsefp/net.sf.eclipsefp.common.core/src/net/sf/eclipsefp/common/core/util/MultiplexedWriter.java new-eclipsefp/net.sf.eclipsefp.common.core/src/net/sf/eclipsefp/common/core/util/MultiplexedWriter.java
--- old-eclipsefp/net.sf.eclipsefp.common.core/src/net/sf/eclipsefp/common/core/util/MultiplexedWriter.java	2006-12-12 11:04:19.000000000 -0300
+++ new-eclipsefp/net.sf.eclipsefp.common.core/src/net/sf/eclipsefp/common/core/util/MultiplexedWriter.java	2006-12-12 11:04:19.000000000 -0300
@@ -1,3 +1,14 @@
+/*******************************************************************************
+ * Copyright (c) 2005, 2006 Thiago Arrais and others.
+ *
+ * All rights reserved. This program and the accompanying materials
+ * are made available under the terms of the Eclipse Public License v1.0
+ * which accompanies this distribution, and is available at
+ * http://www.eclipse.org/legal/epl-v10.html
+ *
+ * Contributors:
+ *     Thiago Arrais - Initial API and implementation
+ *******************************************************************************/
 package net.sf.eclipsefp.common.core.util;
 
 import java.io.IOException;
@@ -51,4 +62,8 @@
 		}
 	}
 
+	public void removeOutput(Writer out) {
+		fOutputs.remove(out);
+	}
+
 }
diff -rN -u old-eclipsefp/net.sf.eclipsefp.common.core.test/src/net/sf/eclipsefp/common/core/test/util/MultiplexedWriterTest.java new-eclipsefp/net.sf.eclipsefp.common.core.test/src/net/sf/eclipsefp/common/core/test/util/MultiplexedWriterTest.java
--- old-eclipsefp/net.sf.eclipsefp.common.core.test/src/net/sf/eclipsefp/common/core/test/util/MultiplexedWriterTest.java	2006-12-12 11:04:19.000000000 -0300
+++ new-eclipsefp/net.sf.eclipsefp.common.core.test/src/net/sf/eclipsefp/common/core/test/util/MultiplexedWriterTest.java	2006-12-12 11:04:19.000000000 -0300
@@ -76,6 +76,17 @@
 		multiplexer.close();
 		assertTrue(out.closed);
 	}
+	
+	public void testDoNotMultiplexToRemovedOutput() throws IOException {
+		final StringWriter output = new StringWriter();
+		MultiplexedWriter multiplexer = new MultiplexedWriter();
+		
+		multiplexer.addOutput(output);
+		multiplexer.removeOutput(output);
+		multiplexer.write("This should not be outputed to the removed writer");
+
+		assertEquals(0, output.toString().length());
+	}
 
 	private void multiplexTo(Writer... outputs) throws InterruptedException, IOException {
 		Writer multiplexer = new MultiplexedWriter(outputs);

END

  P_EMPTY = <<END
<changelog>
</changelog>
END
