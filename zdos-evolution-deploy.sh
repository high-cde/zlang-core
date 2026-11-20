#!/usr/bin/env bash
set -euo pipefail
export ZDOS_SCRIPT_PATH="$(readlink -f -- "$0")"
python3 - "$@" <<'ZDOS_EVOLUTION_PY'

import argparse,base64,datetime,hashlib,io,json,os,re,shutil,subprocess,sys,tarfile,tempfile
from pathlib import Path
PAYLOAD = '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'
a=argparse.ArgumentParser(description='ZDOS Evolution: dry-run default; no network, no push, no cleanup.')
g=a.add_mutually_exclusive_group();g.add_argument('--apply',action='store_true');g.add_argument('--rollback',action='store_true');g.add_argument('--repo-apply',metavar='DIR')
o=a.parse_args()
web=Path(os.environ.get('WEBROOT','/var/www/x-zdos-portal/current')).expanduser().resolve()
back=Path(os.environ.get('BACKUP_ROOT','/root/backups')).expanduser().resolve()
key=hashlib.sha256(str(web).encode()).hexdigest()[:12]
last=back/('zdos-evolution-last-'+key+'.json')
script=Path(os.environ['ZDOS_SCRIPT_PATH']).resolve()
items=['evolution','dsn/zdos-evolution-deploy.sh','dsn/zdos-evolution-pack.tar.gz','index.html']
raw=base64.b64decode(PAYLOAD,validate=True)
def unpack(dest):
 with tarfile.open(fileobj=io.BytesIO(raw),mode='r:xz') as t:
  for m in t.getmembers():
   bits=Path(m.name).parts
   if not m.isfile() or Path(m.name).is_absolute() or '..' in bits or not bits: raise RuntimeError('Archivio non sicuro')
   target=dest/m.name;target.parent.mkdir(parents=True,exist_ok=True)
   with t.extractfile(m) as src,target.open('wb') as out: shutil.copyfileobj(src,out)
def check_target(rel):
 dest=web/rel
 # current webroot may be a release symlink, already resolved; child symlinks are not followed.
 for v in [web]+[web.joinpath(*Path(rel).parts[:i]) for i in range(1,len(Path(rel).parts)+1)]:
  if v.is_symlink(): raise RuntimeError('Symlink non consentito: '+str(v))
 if dest.exists() and (not dest.is_dir() if rel=='evolution' else not dest.is_file()): raise RuntimeError('Tipo target inatteso: '+str(dest))
 return dest

def patched_home():
 home=web/'index.html'
 if not home.is_file():print('AVVISO: home assente; collegamento Evolution non inserito.');return None
 try:text=home.read_bytes().decode('utf-8')
 except UnicodeDecodeError:print('AVVISO: home non UTF-8; patch saltata.');return None
 begin='<!-- ZDOS:EVOLUTION:BEGIN -->';end='<!-- ZDOS:EVOLUTION:END -->'
 blocks=re.compile(re.escape(begin)+r'.*?'+re.escape(end)+r'\n?',re.S)
 if text.count(begin)!=text.count(end) or len(blocks.findall(text))!=text.count(begin):
  print('AVVISO: marker Evolution incompleti; home non modificata.');return None
 clean=blocks.sub('',text)
 nav_anchor='<nav aria-label="Navigazione principale">'
 rail_anchor='<div class="rail" aria-label="Collegamenti rapidi">'
 nav=re.compile(re.escape(nav_anchor)+r'.*?</nav>',re.S)
 matches=list(nav.finditer(clean))
 if len(matches)!=1 or clean.count(rail_anchor)!=1:
  print('AVVISO: anchor home attesi mancanti/ambigui; patch home saltata, pagina /evolution installabile.');return None
 navblock=begin+'<a href="/evolution/">Evolution →</a>'+end
 m=matches[0];clean=clean[:m.end()-6]+navblock+clean[m.end()-6:]
 card=begin+'\n<section id="zdos-evolution-preview" aria-labelledby="zdos-evolution-title"><article class="card"><div class="card-top"><span class="eyebrow">ZDOS EVOLUTION</span><span class="tag purple">IN FASE DI CREAZIONE</span></div><h2 id="zdos-evolution-title">Il prossimo passo, in pubblico.</h2><p>ZDOS Linux come host sperimentale, ZLang per orchestrare i flussi supportati e $DSN come chiave di accesso proposta. Moduli e roadmap con limiti dichiarati: nessun rendimento promesso, nessun servizio indicato come attivo prima dei test.</p><a class="text-link" href="/evolution/">Esplora la presentazione e la roadmap →</a></article></section>\n'+end+'\n'
 return clean.replace(rail_anchor,card+rail_anchor,1).encode('utf-8')

def remove_target(dest):
 if dest.is_symlink(): raise RuntimeError('Rifiuto symlink: '+str(dest))
 if dest.is_dir(): shutil.rmtree(dest)
 elif dest.exists(): dest.unlink()
def restore(snapshot):
 manifest=json.loads((snapshot/'manifest.json').read_text())
 if manifest['webroot']!=str(web) or set(manifest['existed'])!=set(items): raise RuntimeError('Backup non corrispondente')
 for rel in items: check_target(rel)
 for rel in items:
  src=snapshot/'original'/rel;dst=web/rel
  if manifest['existed'][rel] and (not src.exists() or src.is_symlink()): raise RuntimeError('Backup incompleto')
 for rel in items:
  dst=web/rel;remove_target(dst)
  if manifest['existed'][rel]:
   src=snapshot/'original'/rel;dst.parent.mkdir(parents=True,exist_ok=True)
   if src.is_dir(): shutil.copytree(src,dst,symlinks=True)
   else: shutil.copy2(src,dst)

def repo_apply(value):
 repo=Path(value).expanduser().resolve()
 def git(*args):return subprocess.check_output(['git','-C',str(repo),*args],text=True).strip()
 if not repo.is_dir() or git('rev-parse','--show-toplevel')!=str(repo):raise RuntimeError('Richiesta radice di un checkout git locale')
 if git('status','--porcelain','--untracked-files=all'):raise RuntimeError('Checkout non pulito: nessuna modifica')
 if (repo/'evolution').is_symlink():raise RuntimeError('Target evolution symlink')
 branch='zdos/evolution';current=git('symbolic-ref','--short','HEAD')
 exists=subprocess.run(['git','-C',str(repo),'show-ref','--verify','--quiet','refs/heads/'+branch]).returncode==0
 if exists and current!=branch:raise RuntimeError('Branch esistente: passare esplicitamente a zdos/evolution prima di riprovare')
 # Require a configured local identity; never modify global config or supply a fake one.
 git('var','GIT_AUTHOR_IDENT');git('var','GIT_COMMITTER_IDENT')
 with tempfile.TemporaryDirectory(prefix='zdos-evo-repo-') as tmp:
  data=Path(tmp);unpack(data)
  # Do not overwrite any different pre-existing file. This command adds scaffolds only.
  sources=[*data.joinpath('zlang').glob('*.zl'),*data.joinpath('specs').glob('*.md'),data/'ROADMAP.md']
  for f in sources:
   dest=repo/'evolution'/f.relative_to(data)
   for ancestor in [dest,*dest.parents]:
    if ancestor==repo:break
    if ancestor.is_symlink():raise RuntimeError('Symlink nel percorso repo')
   if dest.exists() and (not dest.is_file() or dest.read_bytes()!=f.read_bytes()):raise RuntimeError('File esistente diverso, non sovrascritto: '+str(dest))
  if not exists:git('switch','-c',branch)
  for f in sources:
   dest=repo/'evolution'/f.relative_to(data);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
  git('add','--','evolution/zlang','evolution/specs','evolution/ROADMAP.md')
  if subprocess.run(['git','-C',str(repo),'diff','--cached','--quiet']).returncode==0:print('Repo gia allineato; nessun commit.');return
  subprocess.run(['git','-C',str(repo),'commit','-m','docs: scaffold ZDOS Evolution in fase di creazione'],check=True)
  print('Commit locale:',git('rev-parse','--short','HEAD'),'branch',branch,'; nessun push/PR.')

if o.repo_apply:
 repo_apply(o.repo_apply);sys.exit(0)
if o.rollback:
 if not last.is_file():raise RuntimeError('Nessun rollback registrato per '+str(web))
 record=json.loads(last.read_text());snapshot=back/record['snapshot']
 if snapshot.parent!=back or not snapshot.name.startswith('zdos-evolution-'):raise RuntimeError('Backup path non valido')
 restore(snapshot);last.unlink();print('ROLLBACK OK:',web,'da',snapshot);sys.exit(0)
print('ZDOS Evolution | WEBROOT:',web)
print('Backup:',back,'| Target: /evolution, due artefatti /dsn e patch home index.html. /dsn/index.html e /kira intatti.')
print('9 scaffold solo emit; servizi NON implementati. Nessun accesso rete, nginx reload, pulizia o push.')
home_patch=patched_home()
if home_patch is not None:print('Home: link nav + scheda Evolution gestiti con marker; backup prima della modifica.')
if not o.apply:
 print('DRY-RUN: nessuna modifica. Applicare: bash',script,'--apply')
 print('Repo opzionale: bash',script,'--repo-apply /percorso/checkout-pulito')
 sys.exit(0)
if not web.is_dir():raise RuntimeError('WEBROOT non esistente: niente creato')
for rel in items:check_target(rel)
if not script.is_file():raise RuntimeError('Installer deve essere eseguito da file')
back.mkdir(parents=True,exist_ok=True)
stamp=datetime.datetime.now().astimezone().strftime('%Y%m%d-%H%M%S-%f')
snapshot=back/('zdos-evolution-'+stamp);snapshot.mkdir(mode=0o700)
manifest={'webroot':str(web),'existed':{rel:(web/rel).exists() for rel in items}}
for rel in items:
 src=web/rel;dst=snapshot/'original'/rel
 if manifest['existed'][rel]:
  dst.parent.mkdir(parents=True,exist_ok=True)
  if src.is_dir():shutil.copytree(src,dst,symlinks=True)
  else:shutil.copy2(src,dst)
(snapshot/'manifest.json').write_text(json.dumps(manifest,indent=2))
try:
 with tempfile.TemporaryDirectory(prefix='.zdos-evolution-',dir=web) as tmp:
  stage=Path(tmp);unpack(stage)
  bundle=stage/'zdos-evolution-pack.tar.gz'
  with tarfile.open(bundle,'w:gz') as t:
   for folder in ['zlang','specs','web']:t.add(stage/folder,arcname=folder)
   for f in ['ROADMAP.md','SOURCES.md']:t.add(stage/f,arcname=f)
   t.add(script,arcname='zdos-evolution-deploy.sh')
  dsn=web/'dsn';dsn.mkdir(exist_ok=True)
  # Backup is complete before replacing the previous Evolution directory.
  old=stage/'old-evolution'
  if (web/'evolution').exists():os.replace(web/'evolution',old)
  os.replace(stage/'web/evolution',web/'evolution')
  for src,name in [(script,'zdos-evolution-deploy.sh'),(bundle,'zdos-evolution-pack.tar.gz')]:
   fd,tmpname=tempfile.mkstemp(prefix='.'+name+'.',dir=dsn);os.close(fd)
   temp=Path(tmpname);shutil.copyfile(src,temp);temp.chmod(0o644);os.replace(temp,dsn/name)
  if home_patch is not None:
   fd,tmpname=tempfile.mkstemp(prefix='.index-evolution-',dir=web);os.close(fd)
   temp=Path(tmpname);temp.write_bytes(home_patch);shutil.copymode(web/'index.html',temp);os.replace(temp,web/'index.html')
  pointer=last.with_suffix('.tmp');pointer.write_text(json.dumps({'snapshot':snapshot.name}));os.replace(pointer,last)
except BaseException:
 restore(snapshot);raise
print('APPLY OK | backup:',snapshot)
print('Pagina:',str(web/'evolution/index.html'))
print('Rollback: bash',script,'--rollback (stessi WEBROOT/BACKUP_ROOT se personalizzati)')

ZDOS_EVOLUTION_PY
