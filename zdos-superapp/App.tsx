import React, { useState } from "react";
import { View, Text, TextInput, TouchableOpacity, ScrollView, StyleSheet, Alert } from "react-native";

export default function App() {
  const [screen, setScreen] = useState<"login" | "dashboard">("login");
  const [wallet, setWallet] = useState("");

  const handleLogin = () => {
    if (!wallet) return Alert.alert("Errore", "Inserisci un wallet Solana");
    setScreen("dashboard");
  };

  if (screen === "login") {
    return (
      <View style={s.container}>
        <Text style={s.title}>ZDOS V4</Text>
        <Text style={s.subtitle}>CACHE DESTROYED</Text>
        <TextInput style={s.input} placeholder="Wallet Solana" placeholderTextColor="#666" value={wallet} onChangeText={setWallet} />
        <TouchableOpacity style={s.btnPrimary} onPress={handleLogin}>
          <Text style={s.btnText}>ACCEDI ALLA V4</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <ScrollView style={s.container}>
      <Text style={s.header}>DASHBOARD V4</Text>
      
      <View style={s.card}>
        <Text style={s.cardLabel}>ECCO LE NUOVE FUNZIONI</Text>
        <Text style={s.mono}>Se vedi questo testo, la cache è stata distrutta con successo.</Text>
      </View>

      <TouchableOpacity style={[s.btnSecondary, { borderColor: "#00ff88" }]}>
        <Text style={s.btnTextPrimary}>🌐 ZDOS HUB (zSwap & zQuest)</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[s.btnSecondary, { borderColor: "#ffcc00" }]}>
        <Text style={[s.btnTextPrimary, { color: "#ffcc00" }]}>🐧 PINGUINO FAUCET GAME</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[s.btnSecondary, { borderColor: "#ff3366", marginTop: 24 }]} onPress={() => setScreen("login")}>
        <Text style={[s.btnTextPrimary, { color: "#ff3366" }]}>DISCONNETTI</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#0a0a0a", padding: 20, paddingTop: 50 },
  title: { fontSize: 48, color: "#00ff88", fontWeight: "bold", textAlign: "center", letterSpacing: 8, marginTop: 100 },
  subtitle: { fontSize: 12, color: "#888", textAlign: "center", marginBottom: 48, letterSpacing: 2 },
  header: { color: "#00ff88", fontSize: 24, fontWeight: "bold", letterSpacing: 4, marginBottom: 20 },
  input: { backgroundColor: "#1a1a1a", color: "#fff", padding: 16, borderRadius: 8, borderWidth: 1, borderColor: "#333", marginBottom: 20 },
  btnPrimary: { backgroundColor: "#00ff88", padding: 16, borderRadius: 8, alignItems: "center" },
  btnSecondary: { backgroundColor: "#1a1a1a", padding: 16, borderRadius: 8, alignItems: "center", borderWidth: 1, borderColor: "#333", marginTop: 12 },
  btnText: { color: "#000", fontWeight: "bold", letterSpacing: 2 },
  btnTextPrimary: { color: "#00ff88", fontWeight: "bold", letterSpacing: 1 },
  card: { backgroundColor: "#1a1a1a", padding: 20, borderRadius: 12, marginBottom: 16, borderWidth: 1, borderColor: "#222" },
  cardLabel: { color: "#888", fontSize: 11, letterSpacing: 2, marginBottom: 8 },
  mono: { color: "#fff", fontSize: 12, fontFamily: "monospace" },
});

