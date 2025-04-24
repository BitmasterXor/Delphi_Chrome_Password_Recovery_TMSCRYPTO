<h1>Chrome Password Recovery Tool</h1>
<p>This Delphi application helps recover saved passwords from Google Chrome's profile data. It decrypts the encrypted passwords stored in Chrome for retrieval.</p>

<p align="center">
  <img src="Preview.png" alt="Screenshot of the Chrome Password Recovery Tool" style="max-width:100%; height:auto;">
</p>

<h2>⚠️ Compatibility Warning</h2>
<p><strong>IMPORTANT</strong>: This tool is only compatible with Chrome versions prior to Chrome 127 (released July 2024). Starting with Chrome 127, Google implemented App-Bound Encryption (ABE) which prevents external applications from accessing Chrome's encrypted data directly.</p>

<p>The App-Bound Encryption security feature ties encrypted data to Chrome's application identity, requiring any decryption to happen within Chrome's own process context. This means traditional methods of accessing Chrome's password database no longer work.</p>

<p>For Chrome 127 and newer versions, a completely different approach using process injection and COM interfaces is required. See the "Advanced Usage for Chrome 127+" section below for more details.</p>

<h2>Features</h2>
<ul>
  <li><strong>Recover Saved Passwords:</strong> Extract passwords stored in Chrome.</li>
  <li><strong>Decrypt Passwords:</strong> Decrypts encrypted passwords for access.</li>
  <li><strong>User-Friendly Interface:</strong> Simple and easy to use.</li>
</ul>

<h2>Installation</h2>
<ol>
  <li><strong>Install Required TMS Components:</strong>
    <ul>
      <li>Open the Delphi IDE.</li>
      <li>Click on <strong>File -> Open...</strong> and browse to the TMS Cryptography Suite components folder.</li>
      <li>Look for two files named:
        <ul>
          <li><code>TMSCryptoPkgDEDXE??.dproj</code></li>
          <li><code>TMSCryptoPkgDXE??.dproj</code></li>
          <li><em>(The "??" represents your Delphi IDE version number.)</em></li>
        </ul>
      </li>
      <li>Open both files in the IDE simultaneously. (HOLD DOWN SHIFT and click on them both to ensure both are selected then click the OPEN button)</li>
      <li>Compile the packages:
        <ul>
          <li>Click once to compile the package.</li>
          <li>Right-click on the installable package and select <strong>Install</strong>.</li>
        </ul>
      </li>
      <li>Update the Library Path:
        <ul>
          <li>Go to <strong>Tools -> Options...</strong> and select <strong>Library Path</strong> for Win32.</li>
          <li>Add the path to the components directory where the <code>.dproj</code> files are located.</li>
        </ul>
      </li>
    </ul>
  </li>
  <li><strong>Open Delphi Project:</strong> Open the <code>.dpr</code> file in the Delphi IDE.</li>
  <li><strong>Compile:</strong> Build the project to generate the executable.</li>
  <li><strong>Run:</strong> Execute the tool to start using it.</li>
</ol>

<h2>Usage</h2>
<ol>
  <li><strong>Launch the Application:</strong> Run the tool to automatically locate and scan the Chrome profile directory.</li>
  <li><strong>View Recovered Passwords:</strong> The passwords will be displayed within the application's interface.</li>
</ol>

<h2>Advanced Usage for Chrome 127+</h2>
<p>For Chrome 127 and newer versions, a different approach is needed:</p>
<ol>
  <li><strong>Create Helper DLL:</strong> A specialized DLL needs to be injected into Chrome's process to access its encryption services.</li>
  <li><strong>Process Injection:</strong> The main application needs to:
    <ul>
      <li>Find running Chrome processes</li>
      <li>Inject the helper DLL</li>
      <li>Communicate with Chrome's internal IElevator COM service</li>
      <li>Extract and use the decryption key</li>
    </ul>
  </li>
</ol>
<p>This approach requires advanced programming knowledge and might be flagged by security software as suspicious activity.</p>

<h2>Technical Details</h2>
<p>For Chrome versions before 127:</p>
<ul>
  <li>Chrome stores passwords in an SQLite database file (<code>Login Data</code>)</li>
  <li>Passwords are encrypted using Windows DPAPI</li>
  <li>The encryption key is stored in the <code>Local State</code> JSON file</li>
  <li>AES-GCM encryption is used with a 12-byte IV</li>
</ul>

<p>For Chrome 127+:</p>
<ul>
  <li>App-Bound Encryption adds a new layer of protection</li>
  <li>Decryption key is bound to Chrome's application identity</li>
  <li>Key must be accessed through Chrome's IElevator COM service</li>
  <li>Format changes may affect how passwords are stored and encrypted</li>
</ul>

<h2>Contributing</h2>
<p>Contributions are welcome! If you have improvements or bug fixes, please fork the repository and submit a pull request.</p>

<h2>License</h2>
<p>This project is provided as is without warranty, use at your own risk!</p>

<h2>Contact</h2>
<p>Discord: BitmasterXor</p>

<p align="center">Made with ❤️ by: BitmasterXor and Friends, using Delphi RAD Studio</p>
