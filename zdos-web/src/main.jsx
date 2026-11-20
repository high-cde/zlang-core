import React, { useState } from "react";
import ReactDOM from "react-dom/client";
import "./style.css";

function App() {
  const [screen, setScreen] = useState("login");
  const [wallet, setWallet] = useState("");

  const connectPhantom = async () => {
    if (window.phantom?.solana?.isPhantom || window.solana?.isPhantom) {
      try {
        const provider = window.phantom?.solana || window.solana;
        const resp = await provider.connect();
        setWallet(resp.publicKey.toString());
        setScreen("dashboard");
      } catch (err) {
        alert("Connessione rifiutata.");
      }
    } else {
      alert("Phantom Wallet non trovato! Installalo dal browser.");
    }
  };

  return (
    <div className="container">
      {screen === "login" && (
        <div className="card">
          <h1 className="title">ZDOS WEB3</h1>
          <p className="subtitle">SOVEREIGN MESSENGER</p>
          <button className="btn btn-primary" onClick={connectPhantom}>
            CONNETTI PHANTOM
          </button>
        </div>
      )}

      {screen === "dashboard" && (
        <div>
          <h2 className="header">DASHBOARD</h2>
          <div className="card">
            <p className="label">WALLET ATTIVO</p>
            <p className="mono">{wallet.slice(0, 6)}...{wallet.slice(-4)}</p>
          </div>

          <button className="btn btn-secondary" onClick={() => window.open("https://zswap.x-zdos.it", "_blank")}>
            🌐 zSWAP (Jupiter)
          </button>

          <button className="btn btn-secondary" onClick={() => window.open("https://zquest.x-zdos.it", "_blank")}>
            🐧 zQUEST (Pinguino Game)
          </button>

          <button className="btn btn-danger" onClick={() => setScreen("login")}>
            DISCONNETTI
          </button>
        </div>
      )}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
