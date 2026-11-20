import os

workspace = "/root/zdos/github_workspace"
print("🛡️ [ZDOS LICENSE ENFORCER]: Applicazione licenza sovrana restrittiva...")

sovereign_license = """ZDOS SOVEREIGN ENTERPRISE LICENSE (ZSEL-1.0)
Strictly Proprietary & Confidential

Copyright (c) 2026 high-cde / ZDOS Ecosystem. All Rights Reserved.

1. PROHIBITION OF UNAUTHORIZED USE AND CLONING
Unauthorized duplication, cloning, distribution, or mirroring of this repository, in whole or in part, across any public or private infrastructure without explicit written consent from the copyright holder is strictly prohibited.

2. RESTRICTION ON MODIFICATIONS AND DERIVATIVE WORKS
No entity, user, or automated system is permitted to modify, adapt, reverse engineer, decompile, or create derivative works based upon any source code, documentation, or architecture contained within this repository.

3. PROHIBITION OF INAPPROPRIATE OR UNETHICAL DEPLOYMENT
This software and its underlying ZLang modules must not be utilized for malicious activities, unauthorized surveillance, exploitation, or any deployment that violates the foundational principles of the ZDOS sovereign architecture and the Data Sovereignty Network (DSN).

4. NO WARRANTY
THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY.
"""

count = 0
for repo in os.listdir(workspace):
    path = os.path.join(workspace, repo)
    if os.path.isdir(os.path.join(path, ".git")):
        license_path = os.path.join(path, "LICENSE")
        
        # Scrive o sovrascrive la licenza restrittiva
        with open(license_path, "w", encoding="utf-8") as f:
            f.write(sovereign_license)
        
        os.chdir(path)
        os.system("git add LICENSE")
        os.system("git commit -m 'ZDOS Sovereign Hardening: Applicazione Licenza Proprietaria Restrittiva (ZSEL-1.0)' || true")
        branch = os.popen("git branch --show-current").read().strip() or "main"
        os.system(f"git push origin {branch} || git push origin master || true")
        count += 1
        print(f"🛡️ Licenza applicata e pusciata per: {repo}")

print(f"✨ [PROTEZIONE COMPLETATA]: Licenza sovrana applicata con successo a {count} repository!")
