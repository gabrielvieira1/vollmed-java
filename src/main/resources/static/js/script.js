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

      const url = `/pacientes/buscar?nome=${encodeURIComponent(termo)}`;
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

  // Busca de Médicos - seguindo padrão do projeto
  const searchDoctorInput = document.getElementById("searchDoctorInput");
  const searchDoctorBtn = document.getElementById("searchDoctorBtn");
  const searchDoctorResults = document.getElementById("search-results-doctor");
  const searchDoctorOutput = document.getElementById("search-output-doctor");

  if (
    searchDoctorInput &&
    searchDoctorBtn &&
    searchDoctorResults &&
    searchDoctorOutput
  ) {
    console.log("=== ELEMENTOS DE BUSCA DE MÉDICOS ENCONTRADOS ===");

    function realizarBuscaMedicos() {
      const termo = searchDoctorInput.value.trim();
      console.log("=== BUSCA DE MÉDICOS INICIADA ===");
      console.log("Termo:", termo);

      if (!termo) {
        alert("Digite um nome para buscar");
        return;
      }

      // Mostra a seção de resultados
      searchDoctorResults.style.display = "block";
      searchDoctorOutput.innerHTML =
        '<i class="fas fa-spinner fa-spin"></i> Buscando...';

      const url = `/medicos/buscar?nome=${encodeURIComponent(termo)}`;
      console.log("URL de busca:", url);

      fetch(url, {
        method: "GET",
        headers: {
          Accept: "application/json",
        },
      })
        .then((response) => {
          console.log("=== RESPOSTA DA BUSCA DE MÉDICOS ===");
          console.log("Status:", response.status);

          if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
          }
          return response.json();
        })
        .then((data) => {
          console.log("=== DADOS DE MÉDICOS RECEBIDOS ===");
          console.log("Data:", data);
          console.log("Array?", Array.isArray(data));
          console.log("Length:", data.length);

          let html = `<strong>🔍 Busca por:</strong> "${termo}"<br>`;
          html += `<strong>📊 Resultados:</strong> ${data.length} médico(s)<br><br>`;

          if (data.length > 0) {
            data.forEach((m) => {
              html += `<div style="background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 5px; border-left: 4px solid #007bff;">`;
              html += `<strong>${m.nome}</strong><br>`;
              html += `📧 ${m.email}<br>`;
              html += `🏥 CRM: ${m.crm}<br>`;
              html += `🩺 ${m.especialidade}`;
              html += `</div>`;
            });
          } else {
            html +=
              '<div style="color: #6c757d;">Nenhum médico encontrado.</div>';
          }

          searchDoctorOutput.innerHTML = html;
          console.log("=== HTML DE MÉDICOS ATUALIZADO ===");
        })
        .catch((error) => {
          console.error("=== ERRO NA BUSCA DE MÉDICOS ===");
          console.error("Error:", error);
          searchDoctorOutput.innerHTML = `
          <div style="color: #dc3545; background: #f8d7da; padding: 10px; border-radius: 5px;">
            <strong>❌ Erro:</strong> ${error.message}
          </div>`;
        });
    }

    // Event listeners - seguindo padrão do projeto
    searchDoctorBtn.addEventListener("click", function () {
      console.log("=== BOTÃO DE BUSCA DE MÉDICOS CLICADO ===");
      realizarBuscaMedicos();
    });

    searchDoctorInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        console.log("=== ENTER PRESSIONADO NA BUSCA DE MÉDICOS ===");
        e.preventDefault();
        realizarBuscaMedicos();
      }
    });

    console.log("=== EVENT LISTENERS DE BUSCA DE MÉDICOS ADICIONADOS ===");
  }

  // Busca de pacientes no formulário de consulta - seguindo padrão do projeto
  const searchPacienteInput = document.getElementById("searchPaciente");
  const btnBuscarPaciente = document.getElementById("btnBuscarPaciente");
  const pacienteResultsDiv = document.getElementById("paciente-results");
  const pacienteListDiv = document.getElementById("paciente-list");
  const pacienteIdInput = document.getElementById("pacienteId");
  const selectedPacienteDiv = document.getElementById("selected-paciente");
  const selectedPacienteNome = document.getElementById(
    "selected-paciente-nome"
  );
  const btnLimparPaciente = document.getElementById("btnLimparPaciente");

  if (searchPacienteInput && btnBuscarPaciente && pacienteIdInput) {
    console.log(
      "=== BUSCA DE PACIENTE NO FORMULÁRIO DE CONSULTA ENCONTRADA ==="
    );

    // Se já tem paciente selecionado (edição), carregar nome
    if (pacienteIdInput.value) {
      carregarPacienteSelecionadoConsulta(pacienteIdInput.value);
    }

    function buscarPacientesConsulta() {
      const nome = searchPacienteInput.value.trim();
      console.log("=== BUSCA DE PACIENTE PARA CONSULTA ===");
      console.log("Nome:", nome);

      if (!nome) {
        alert("Digite um nome para buscar");
        return;
      }

      const url = `/pacientes/buscar?nome=${encodeURIComponent(nome)}`;
      console.log("URL:", url);

      fetch(url)
        .then((response) => response.json())
        .then((pacientes) => {
          console.log("Pacientes encontrados:", pacientes.length);

          if (pacientes.length === 0) {
            pacienteListDiv.innerHTML =
              '<div style="padding: 15px; text-align: center; color: #666;">Nenhum paciente encontrado</div>';
          } else {
            pacienteListDiv.innerHTML = pacientes
              .map(
                (p) => `
                            <div class="paciente-item" data-id="${p.id}" data-nome="${p.nome}" 
                                 style="padding: 12px; border-bottom: 1px solid #eee; cursor: pointer; transition: background 0.2s;"
                                 onmouseover="this.style.background='#f8f9fa'" 
                                 onmouseout="this.style.background='white'">
                                <strong>${p.nome}</strong><br>
                                <small style="color: #666;">CPF: ${p.cpfFormatado} | Email: ${p.email}</small>
                            </div>
                        `
              )
              .join("");

            // Adicionar event listeners
            document.querySelectorAll(".paciente-item").forEach((item) => {
              item.addEventListener("click", function () {
                const id = this.dataset.id;
                const nome = this.dataset.nome;
                selecionarPacienteConsulta(id, nome);
              });
            });
          }
          pacienteResultsDiv.style.display = "block";
        })
        .catch((error) => {
          console.error("Erro ao buscar pacientes:", error);
          alert("Erro ao buscar pacientes. Tente novamente.");
        });
    }

    function selecionarPacienteConsulta(id, nome) {
      console.log("Paciente selecionado:", id, nome);
      pacienteIdInput.value = id;
      selectedPacienteNome.textContent = nome;
      selectedPacienteDiv.style.display = "block";
      pacienteResultsDiv.style.display = "none";
      searchPacienteInput.value = "";
    }

    function carregarPacienteSelecionadoConsulta(id) {
      fetch(`/pacientes/${id}`)
        .then((response) => response.json())
        .then((paciente) => {
          selectedPacienteNome.textContent = paciente.nome;
          selectedPacienteDiv.style.display = "block";
        })
        .catch((error) => console.error("Erro ao carregar paciente:", error));
    }

    btnBuscarPaciente.addEventListener("click", buscarPacientesConsulta);
    searchPacienteInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        e.preventDefault();
        buscarPacientesConsulta();
      }
    });

    if (btnLimparPaciente) {
      btnLimparPaciente.addEventListener("click", function () {
        pacienteIdInput.value = "";
        selectedPacienteDiv.style.display = "none";
        searchPacienteInput.value = "";
        pacienteResultsDiv.style.display = "none";
      });
    }

    console.log("=== BUSCA DE PACIENTE NO FORMULÁRIO CONFIGURADA ===");
  }

  // Busca de médicos no formulário de consulta - seguindo padrão do projeto
  const searchMedicoInput = document.getElementById("searchMedico");
  const btnBuscarMedico = document.getElementById("btnBuscarMedico");
  const medicoResultsDiv = document.getElementById("medico-results");
  const medicoListDiv = document.getElementById("medico-list");
  const medicoSelect = document.getElementById("idMedico");
  const selectedMedicoDiv = document.getElementById("selected-medico");
  const selectedMedicoNome = document.getElementById("selected-medico-nome");
  const selectedMedicoEspec = document.getElementById("selected-medico-espec");
  const btnLimparMedico = document.getElementById("btnLimparMedico");

  if (searchMedicoInput && btnBuscarMedico && medicoSelect) {
    console.log("=== BUSCA DE MÉDICO NO FORMULÁRIO DE CONSULTA ENCONTRADA ===");

    function buscarMedicosConsulta() {
      const nome = searchMedicoInput.value.trim();
      console.log("=== BUSCA DE MÉDICO PARA CONSULTA ===");
      console.log("Nome:", nome);

      if (!nome) {
        alert("Digite um nome para buscar");
        return;
      }

      const url = `/medicos/buscar?nome=${encodeURIComponent(nome)}`;
      console.log("URL:", url);

      fetch(url)
        .then((response) => response.json())
        .then((medicos) => {
          console.log("Médicos encontrados:", medicos.length);

          if (medicos.length === 0) {
            medicoListDiv.innerHTML =
              '<div style="padding: 15px; text-align: center; color: #666;">Nenhum médico encontrado</div>';
          } else {
            medicoListDiv.innerHTML = medicos
              .map(
                (m) => `
                            <div class="medico-item" data-id="${m.id}" data-nome="${m.nome}" data-espec="${m.especialidade}"
                                 style="padding: 12px; border-bottom: 1px solid #eee; cursor: pointer; transition: background 0.2s;"
                                 onmouseover="this.style.background='#f8f9fa'" 
                                 onmouseout="this.style.background='white'">
                                <strong>${m.nome}</strong> - <span style="color: #007bff;">${m.especialidade}</span><br>
                                <small style="color: #666;">CRM: ${m.crm} | Email: ${m.email}</small>
                            </div>
                        `
              )
              .join("");

            // Adicionar event listeners
            document.querySelectorAll(".medico-item").forEach((item) => {
              item.addEventListener("click", function () {
                const id = this.dataset.id;
                const nome = this.dataset.nome;
                const espec = this.dataset.espec;
                selecionarMedicoConsulta(id, nome, espec);
              });
            });
          }
          medicoResultsDiv.style.display = "block";
        })
        .catch((error) => {
          console.error("Erro ao buscar médicos:", error);
          alert("Erro ao buscar médicos. Tente novamente.");
        });
    }

    function selecionarMedicoConsulta(id, nome, especialidade) {
      console.log("Médico selecionado:", id, nome, especialidade);

      // Limpar options existentes e adicionar a nova
      medicoSelect.innerHTML = `<option value="${id}" selected>${nome} - ${especialidade}</option>`;

      selectedMedicoNome.textContent = nome;
      selectedMedicoEspec.textContent = especialidade;
      selectedMedicoDiv.style.display = "block";
      medicoResultsDiv.style.display = "none";
      searchMedicoInput.value = "";
    }

    btnBuscarMedico.addEventListener("click", buscarMedicosConsulta);
    searchMedicoInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter") {
        e.preventDefault();
        buscarMedicosConsulta();
      }
    });

    if (btnLimparMedico) {
      btnLimparMedico.addEventListener("click", function () {
        medicoSelect.value = "";
        selectedMedicoDiv.style.display = "none";
        searchMedicoInput.value = "";
        medicoResultsDiv.style.display = "none";
      });
    }

    console.log("=== BUSCA DE MÉDICO NO FORMULÁRIO CONFIGURADA ===");
  }

  // Debug do formulário de usuários
  const formUsuario = document.querySelector('form[action*="usuarios"]');
  if (formUsuario) {
    console.log("=== FORMULÁRIO DE USUÁRIO ENCONTRADO ===");

    formUsuario.addEventListener("submit", function (e) {
      console.log("\n=== FORMULÁRIO DE USUÁRIO SENDO ENVIADO ===");

      const formData = new FormData(formUsuario);
      console.log("Dados do formulário:");
      for (let [key, value] of formData.entries()) {
        console.log(`  ${key}: ${value}`);
      }

      // Verifica campos obrigatórios
      const nome = formUsuario.querySelector("#nome");
      const email = formUsuario.querySelector("#email");
      const perfil = formUsuario.querySelector("#perfil");
      const senha = formUsuario.querySelector("#senha");
      const id = formUsuario.querySelector('input[name="id"]');

      console.log("Validações:");
      console.log(
        `  Nome válido? ${nome.checkValidity()} - Valor: "${nome.value}"`
      );
      console.log(
        `  Email válido? ${email.checkValidity()} - Valor: "${email.value}"`
      );
      console.log(
        `  Perfil válido? ${perfil.checkValidity()} - Valor: "${perfil.value}"`
      );
      console.log(
        `  Senha válida? ${senha.checkValidity()} - Valor: "${
          senha.value ? "[PREENCHIDA]" : "[VAZIA]"
        }"`
      );
      console.log(`  ID: ${id.value || "null (novo usuário)"}`);

      if (!formUsuario.checkValidity()) {
        console.log(
          "❌ FORMULÁRIO INVÁLIDO - submit será bloqueado pelo HTML5"
        );
        e.preventDefault();
        formUsuario.reportValidity();
        return false;
      }

      console.log("✅ Formulário válido - enviando para servidor...");
    });
  }
});
