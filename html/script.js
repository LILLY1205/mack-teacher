// ============================================================================
// MACK-TEACHER NUI SCRIPT
// ============================================================================

// Utility: post to Lua NUI callbacks
function post(endpoint, data) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    }).catch(function(error) {
        console.error('[mack-teacher] Post Error ' + endpoint + ':', error);
    });
}

// ============================================================================
// NUI MESSAGE LISTENER
// ============================================================================

window.addEventListener('message', function(event) {
    var data = event.data;

    if (data.action === 'openTeacherMenu') {
        openTeacherMenu(data);
    } else if (data.action === 'openBook') {
        openBook(data.bookData);
    } else if (data.action === 'closeBook') {
        closeBook();
    } else if (data.action === 'openLeaderboard') {
        openLeaderboard(data.leaderboard, data.playerCitizenId);
    } else if (data.action === 'closeAll') {
        closeAll();
    }
});

// ============================================================================
// TEACHER MENU (Clipboard)
// ============================================================================

function openTeacherMenu(data) {
    // Hide other menus
    document.getElementById('leaderboardMenu').classList.remove('visible');
    document.getElementById('bookOverlay').classList.remove('visible');

    // Update header
    if (data.lang && data.lang.teacher_menu) {
        document.getElementById('teacherTitle').textContent = data.lang.teacher_menu;
    }

    // Update clock button visibility based on state
    var btnClockIn = document.getElementById('btnClockIn');
    var btnClockOut = document.getElementById('btnClockOut');
    var btnStartClass = document.getElementById('btnStartClass');

    if (data.isClockedIn) {
        btnClockIn.style.display = 'none';
        btnClockOut.style.display = '';
        btnStartClass.style.display = '';
    } else {
        btnClockIn.style.display = '';
        btnClockOut.style.display = 'none';
        btnStartClass.style.display = 'none';
    }

    // Show menu
    document.getElementById('teacherMenu').classList.add('visible');
}

function closeUI() {
    document.getElementById('teacherMenu').classList.remove('visible');
    post('closeUI');
}

// ============================================================================
// CLOCK IN / OUT / START CLASS / LEADERBOARD (from menu buttons)
// ============================================================================

function clockIn() {
    post('clockIn');
    document.getElementById('teacherMenu').classList.remove('visible');
}

function clockOut() {
    post('clockOut');
    document.getElementById('teacherMenu').classList.remove('visible');
}

function startClass() {
    post('startClass');
    document.getElementById('teacherMenu').classList.remove('visible');
}

function viewLeaderboard() {
    post('viewLeaderboard');
    document.getElementById('teacherMenu').classList.remove('visible');
}

// ============================================================================
// BOOK UI (turn.js)
// ============================================================================

function openBook(bookData) {
    // Hide clipboard menus
    document.getElementById('teacherMenu').classList.remove('visible');
    document.getElementById('leaderboardMenu').classList.remove('visible');

    // Destroy existing turn.js instance if present
    if ($('#book_pages').turn('is')) {
        $('#book_pages').turn('destroy');
    }
    $('#book_pages').empty();

    // Build pages from bookData (matching newspaper pattern)
    if (bookData && bookData.pages && bookData.pages.length > 0) {
        for (var i = 0; i < bookData.pages.length; i++) {
            var page = bookData.pages[i];
            var pageDiv = $('<div class="page_row" style="background: url(images/paper.png); background-size: 100% 100%;"></div>');

            if (page.type === 'title') {
                pageDiv.append(buildTitlePage(page));
            } else {
                pageDiv.append(buildContentPage(page));
            }

            $('#book_pages').append(pageDiv);
        }
    } else {
        // Empty book fallback
        var emptyPage = $('<div class="page_row" style="background: url(images/paper.png); background-size: 100% 100%;"></div>');
        emptyPage.append('<div class="book-title-page"><h1>Empty Book</h1><h2>Nothing to read today...</h2></div>');
        $('#book_pages').append(emptyPage);
    }

    // Show book overlay
    document.getElementById('bookOverlay').classList.add('visible');

    // Initialize turn.js (matching newspaper pattern)
    $('#book_pages').turn({
        gradients: true,
        acceleration: true
    });
}

function buildTitlePage(page) {
    var html = '<div class="book-title-page">';
    html += '<h1>' + escapeHtml(page.content || 'School Book') + '</h1>';
    if (page.category) {
        html += '<h2>' + escapeHtml(page.category) + '</h2>';
    }
    html += '</div>';
    return html;
}

function buildContentPage(page) {
    var html = '<div class="book-content-page">';
    if (page.category) {
        html += '<div class="page-category">' + escapeHtml(page.category) + '</div>';
    }
    html += '<div class="page-text">' + escapeHtml(page.content || '') + '</div>';
    html += '<div class="page-decoration">&#9753;</div>';
    html += '</div>';
    return html;
}

function closeBook() {
    // Destroy turn.js instance before closing
    if ($('#book_pages').turn('is')) {
        $('#book_pages').turn('destroy');
    }

    document.getElementById('bookOverlay').classList.remove('visible');
    post('closeBook');
}

// ============================================================================
// LEADERBOARD
// ============================================================================

function openLeaderboard(leaderboard, playerCitizenId) {
    // Hide other menus
    document.getElementById('teacherMenu').classList.remove('visible');
    document.getElementById('bookOverlay').classList.remove('visible');

    // Render both lists
    var students = (leaderboard && leaderboard.students) ? leaderboard.students : [];
    var teachers = (leaderboard && leaderboard.teachers) ? leaderboard.teachers : [];

    renderLeaderboardList('studentList', students, playerCitizenId, 'No students on the leaderboard yet.');
    renderLeaderboardList('teacherList', teachers, playerCitizenId, 'No teachers on the leaderboard yet.');

    // Reset to students tab
    switchLeaderboardTab('students');

    document.getElementById('leaderboardMenu').classList.add('visible');
}

function renderLeaderboardList(elementId, entries, playerCitizenId, emptyMessage) {
    var listEl = document.getElementById(elementId);
    listEl.innerHTML = '';

    if (entries && entries.length > 0) {
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            var rank = i + 1;

            var item = document.createElement('div');
            item.className = 'leaderboard-item';

            // Highlight current player
            if (entry.citizenid === playerCitizenId) {
                item.classList.add('highlight');
            }

            // Rank
            var rankEl = document.createElement('span');
            rankEl.className = 'leaderboard-rank';
            if (rank === 1) rankEl.classList.add('gold');
            else if (rank === 2) rankEl.classList.add('silver');
            else if (rank === 3) rankEl.classList.add('bronze');
            rankEl.textContent = '#' + rank;

            // Name
            var nameEl = document.createElement('span');
            nameEl.className = 'leaderboard-name';
            nameEl.textContent = entry.name || 'Unknown';

            // XP
            var xpEl = document.createElement('span');
            xpEl.className = 'leaderboard-xp';
            xpEl.textContent = (entry.totalXP || 0) + ' XP';

            item.appendChild(rankEl);
            item.appendChild(nameEl);
            item.appendChild(xpEl);
            listEl.appendChild(item);
        }
    } else {
        var empty = document.createElement('div');
        empty.className = 'leaderboard-item';
        empty.innerHTML = '<span class="leaderboard-name" style="text-align:center;width:100%;font-style:italic;">' + escapeHtml(emptyMessage) + '</span>';
        listEl.appendChild(empty);
    }
}

function switchLeaderboardTab(tab) {
    var tabStudents = document.getElementById('tabStudents');
    var tabTeachers = document.getElementById('tabTeachers');
    var studentsPane = document.getElementById('studentsPane');
    var teachersPane = document.getElementById('teachersPane');

    if (tab === 'teachers') {
        tabStudents.classList.remove('active');
        tabTeachers.classList.add('active');
        studentsPane.style.display = 'none';
        teachersPane.style.display = '';
    } else {
        tabStudents.classList.add('active');
        tabTeachers.classList.remove('active');
        studentsPane.style.display = '';
        teachersPane.style.display = 'none';
    }
}

function closeLeaderboard() {
    document.getElementById('leaderboardMenu').classList.remove('visible');
    post('closeUI');
}

// ============================================================================
// CLOSE ALL
// ============================================================================

function closeAll() {
    document.getElementById('teacherMenu').classList.remove('visible');
    document.getElementById('leaderboardMenu').classList.remove('visible');

    if ($('#book_pages').turn('is')) {
        $('#book_pages').turn('destroy');
    }
    document.getElementById('bookOverlay').classList.remove('visible');
}

// ============================================================================
// ESC KEY HANDLER
// ============================================================================

$(document).keyup(function(e) {
    if (e.key === 'Escape') {
        if (document.getElementById('bookOverlay').classList.contains('visible')) {
            // Don't allow ESC to close book during class (progress bar controls it)
            return;
        }
        if (document.getElementById('teacherMenu').classList.contains('visible')) {
            closeUI();
        } else if (document.getElementById('leaderboardMenu').classList.contains('visible')) {
            closeLeaderboard();
        }
    }
});

// ============================================================================
// UTILITY
// ============================================================================

function escapeHtml(text) {
    if (!text) return '';
    var map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, function(m) { return map[m]; });
}
