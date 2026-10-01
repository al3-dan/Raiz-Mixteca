const lotes = [
  {
    codigo: "LOT-000001",
    producto: "Miel multifloral",
    tipo: "Miel",
    productor: "Productor de ejemplo",
    comunidad: "Región Mixteca, Oaxaca",
    fecha: "2026-09-20",
    proceso: "Cosecha, filtrado y envasado artesanal."
  },
  {
    codigo: "LOT-000002",
    producto: "Pulque natural",
    tipo: "Pulque",
    productor: "Productor de ejemplo",
    comunidad: "Región Mixteca, Oaxaca",
    fecha: "2026-09-22",
    proceso: "Extracción, fermentación controlada y registro del lote."
  }
];

const select = document.getElementById("lotSelect");

function renderOptions() {
  lotes.forEach((lote, index) => {
    const option = document.createElement("option");
    option.value = index;
    option.textContent = `${lote.codigo} — ${lote.producto}`;
    select.appendChild(option);
  });
}

function renderLote(index = 0) {
  const lote = lotes[index];
  document.getElementById("lotCode").textContent = lote.codigo;
  document.getElementById("lotProduct").textContent = lote.producto;
  document.getElementById("lotType").textContent = lote.tipo;
  document.getElementById("lotProducer").textContent = lote.productor;
  document.getElementById("lotCommunity").textContent = lote.comunidad;
  document.getElementById("lotDate").textContent = lote.fecha;
  document.getElementById("lotProcess").textContent = lote.proceso;
}

if (select) {
  renderOptions();
  renderLote(0);
  select.addEventListener("change", (event) => {
    renderLote(Number(event.target.value));
  });
}
