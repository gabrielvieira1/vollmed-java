$("#deleteModal").on("show.bs.modal", function (e) {
  const modal = $(this);

  const id = $(e.relatedTarget).data("id");
  modal.find('input[name="id"]').val(id);

  const url = $(e.relatedTarget).data("url");
  modal.find("form").attr("action", url);
});

$("#updateModal").on("show.bs.modal", function (e) {
  const modal = $(this);

  const id = $(e.relatedTarget).data("id");
  modal.find('input[name="id"]').val(id);

  const url = $(e.relatedTarget).data("url");
  modal.find("form").attr("action", url);
});

document.addEventListener("DOMContentLoaded", function () {
  const especialidadeSelect = document.getElementById("especialidade");
  if (especialidadeSelect) {
    const medicoSelect = document.getElementById("idMedico");

    especialidadeSelect.addEventListener("change", function () {
      const especialidade = especialidadeSelect.value;

      medicoSelect.innerHTML = '<option value="">Selecione um médico</option>';

      if (especialidade) {
        fetch("/medicos/" + especialidade)
          .then((response) => {
            if (!response.ok) {
              throw new Error("Network response was not ok");
            }
            return response.json();
          })
          .then((data) => {
            data.forEach((medico) => {
              const option = document.createElement("option");
              option.value = medico.id;
              option.text = medico.nome;
              medicoSelect.appendChild(option);
            });
          })
          .catch((error) => console.error("Erro:", error));
      }
    });
  }

  // PDF Export functionality - seguindo padrão do projeto
  const pdfCheckboxes = document.querySelectorAll(".pdf-crypto-check");
  pdfCheckboxes.forEach(function (checkbox) {
    checkbox.addEventListener("change", function () {
      console.log("=== CHECKBOX PDF MUDOU ===");
      console.log("Checkbox marcado:", this.checked);

      const container = this.closest(".pdf-export-container");
      const link = container.querySelector(".pdf-link");
      const relatorioId = link.getAttribute("data-id");
      const criptografado = this.checked;

      console.log("Relatório ID:", relatorioId);
      console.log("Estado da criptografia:", criptografado);

      // Atualizar href do link
      const baseUrl = `/relatorios/${relatorioId}/exportar-pdf`;
      const novoHref = `${baseUrl}?criptografado=${criptografado}`;
      link.href = novoHref;

      console.log("Link atualizado para:", novoHref);

      // Feedback visual no emoji
      const emoji = this.nextElementSibling;
      if (criptografado) {
        emoji.style.color = "#28a745"; // Verde quando marcado
        emoji.textContent = "🔒";
      } else {
        emoji.style.color = "#666"; // Cinza quando desmarcado
        emoji.textContent = "🔓";
      }
    });
  });

  document.querySelectorAll(".pagination a.disabled").forEach(function (link) {
    link.addEventListener("click", function (event) {
      event.preventDefault();
    });
  });

  function openModal(modal) {
    modal.style.display = "block";
  }

  function closeModal(modal) {
    modal.style.display = "none";
  }

  function setupModalTriggers(modalId) {
    const modal = document.querySelector(modalId);

    document.querySelectorAll(`[href="${modalId}"]`).forEach((trigger) => {
      trigger.addEventListener("click", function (event) {
        event.preventDefault();
        const id = this.getAttribute("data-id");
        const url = this.getAttribute("data-url");
        modal.querySelector('input[name="id"]').value = id;
        modal.querySelector("form").setAttribute("action", url);
        openModal(modal);
      });
    });

    if (modal) {
      modal.querySelectorAll('[data-dismiss="modal"]').forEach((button) => {
        button.addEventListener("click", function () {
          closeModal(modal);
        });
      });

      modal.addEventListener("click", function (event) {
        if (event.target === modal) {
          closeModal(modal);
        }
      });
    }
  }

  setupModalTriggers("#deleteModal");
  setupModalTriggers("#updateModal");

  // Busca de Pacientes - seguindo padrão do projeto
  const searchInput = document.getElementById("searchPatientInput");
  const searchBtn = document.getElementById("searchPatientBtn");
  const searchResults = document.getElementById("search-results");
  const searchOutput = document.getElementById("search-output");

  if (searchInput && searchBtn && searchResults && searchOutput) {
    console.log("=== ELEMENTOS DE BUSCA ENCONTRADOS ===");

    function realizarBuscaPacientes() {
      const termo = searchInput.value.trim();
      console.log("=== BUSCA DE PACIENTES INICIADA ===");
      console.log("Termo:", termo);

      if (!termo) {
        alert("Digite um nome para buscar");
        return;
      }

      // Mostra a seção de resultados
      searchResults.style.display = "block";
      searchOutput.innerHTML =
        '<i class="fas fa-spinner fa-spin"></i> Buscando...';

      const url = `/pacientes/buscar-vulneravel?nome=${encodeURIComponent(
        termo
      )}`;
      console.log("URL de busca:", url);

      fetch(url, {
        method: "GET",
        headers: {
          Accept: "application/json",
        },
      })
        .then((response) => {
          console.log("=== RESPOSTA DA BUSCA ===");
          console.log("Status:", response.status);

          if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
          }
          return response.json();
        })
        .then((data) => {
          console.log("=== DADOS DE PACIENTES RECEBIDOS ===");
          console.log("Data:", data);
          console.log("Array?", Array.isArray(data));
          console.log("Length:", data.length);

          let html = `<strong>🔍 Busca por:</strong> "${termo}"<br>`;
          html += `<strong>📊 Resultados:</strong> ${data.length} paciente(s)<br><br>`;

          if (data.length > 0) {
            data.forEach((p) => {
              html += `<div style="background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 5px; border-left: 4px solid #007bff;">`;
              html += `<strong>${p.nome}</strong><br>`;
              html += `📧 ${p.email}<br>`;
              html += `📱 ${p.telefoneFormatado}<br>`;
              html += `🆔 ${p.cpfFormatado}`;
              html += `</div>`;
            });
          } else {
            html +=
              '<div style="color: #6c757d;">Nenhum paciente encontrado.</div>';
          }

          searchOutput.innerHTML = html;
          console.log("=== HTML DE PACIENTES ATUALIZADO ===");
        })
        .catch((error) => {
          console.error("=== ERRO NA BUSCA DE PACIENTES ===");
          console.error("Error:", error);
          searchOutput.innerHTML = `
          <div style="color: #dc3545; background: #f8d7da; padding: 10px; border-radius: 5px;">
            <strong>❌ Erro:</strong> ${error.message}
          </div>`;
        });
    }

    // Event listeners - seguindo padrão do projeto
    searchBtn.addEventListener("click", function () {
      console.log("=== BOTÃO DE BUSCA CLICADO ===");
      realizarBuscaPacientes();
    });

    searchInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        console.log("=== ENTER PRESSIONADO NA BUSCA ===");
        e.preventDefault();
        realizarBuscaPacientes();
      }
    });

    console.log("=== EVENT LISTENERS DE BUSCA ADICIONADOS ===");
  }
});
