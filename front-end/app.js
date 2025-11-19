const API_BASE = "http://localhost:5000";

async function createStore() {
  const name = document.getElementById("storeName").value;
  const res = await fetch(`${API_BASE}/store`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name })
  });
  const data = await res.json();
  alert("Store created: " + data.id);
  loadStores();
}

async function loadStores() {
  try {
    const res = await fetch(`${API_BASE}/store`);
    const data = await res.json();
    const list = document.getElementById("storeList");
    list.innerHTML = "";
    data.stores.forEach(store => {
      const li = document.createElement("li");
      li.textContent = `${store.name} (ID: ${store.id})`;
      list.appendChild(li);
    });
  } catch (err) {
    console.error("Failed to load stores:", err);
  }
}

async function addItem() {
  const name = document.getElementById("itemName").value;
  const price = parseFloat(document.getElementById("itemPrice").value);
  const store_id = document.getElementById("itemStoreId").value;

  const res = await fetch(`${API_BASE}/item`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, price, store_id })
  });

  const data = await res.json();
  alert("Item added: " + data.id);
}

loadStores();