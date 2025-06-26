/**
 * QuantumLog
 * License: MIT
 * Source: https://github.com/JoeFerri/QuantumLog
 * Copyright (c) 2025 Giuseppe Ferri <jfinfoit@gmail.com>
 */



class PlantUMLDocs {

    /**
     * Loads and Sets mock data for various diagram types used in the documentation system.
     * The mock data includes filenames and titles for each diagram type category.
     */
    async loadMockData() {
        const mockData = {
            'usecases': [
                { filename: 'ql-usecases.png', title: 'Use Cases' }
            ],
            'components': [
                { filename: 'ql-components_future_features.png', title: 'Components Future Features' },
                { filename: 'ql-components_main_cargoroutestrategy.png', title: 'CargoRouteStrategy' },
                { filename: 'ql-components_main_limitsstrategy.png', title: 'LimitsStrategy' },
                { filename: 'ql-components_main_shipstrategy.png', title: 'ShipStrategy' },
                { filename: 'ql-components_main_starmapcargorouteboard.png', title: 'StarMapCargoRouteBoard' },
                { filename: 'ql-components_main_starmapdb.png', title: 'StarMapDB' },
                { filename: 'ql-components_main_strategyboard.png', title: 'StrategyBoard' },
                { filename: 'ql-components_main_timeboard.png', title: 'TimeBoard' },
                { filename: 'ql-components_main.png', title: 'Components Main' },
            ],
            'code': [
                { filename: 'ql-code_cargogradecode.png', title: 'CargoGradeCode' },
                { filename: 'ql-code_cargoroutestrategycode.png', title: 'CargoRouteStrategyCode' },
                { filename: 'ql-code_transportguildrankcode.png', title: 'TransportGuildRankCode' }
            ],
            'wbs': [
                { filename: 'ql-wbs_artifacts.png', title: 'WBS Artifacts' }
            ]
        };

        this.mockData = mockData;
    }

    /**
     * Initializes the PlantUML documentation system.
     * @constructor
     */
    constructor() {
        this.currentType = null;
        this.currentDiagramIndex = 0;
        this.diagrams = [];
        this.diagramTypes = {
            'usecases': {
                title: 'Use Cases',
                folder: 'ql-usecases'
            },
            'components': {
                title: 'Components', 
                folder: 'ql-components'
            },
            'code': {
                title: 'Code',
                folder: 'ql-code'
            },
            'wbs': {
                title: 'WBS',
                folder: 'ql-wbs'
            }
        };
        this.mockData = null;
        
        this.init();
    }

    /**
     * System initialization
     */
    async init() {
        try {
            await this.loadMockData();
        } catch (error) {
            console.error('Error loading the list:', error);
            this.showError('Error loading the list of diagrams');
        }
        this.bindEvents();
        this.showPage('home');
    }

    /**
     * Event Binding
     */
    bindEvents() {
        // Eventi per i tipi di diagramma
        document.querySelectorAll('.type-card').forEach(card => {
            card.addEventListener('click', (e) => {
                const type = e.currentTarget.dataset.type;
                this.showDiagramList(type);
            });
        });

        // Navigation
        document.getElementById('back-to-home').addEventListener('click', () => {
            this.showPage('home');
        });

        document.getElementById('home-button').addEventListener('click', () => {
            this.showPage('home');
        });

        document.getElementById('prev-diagram').addEventListener('click', () => {
            this.navigateDiagram(-1);
        });

        document.getElementById('next-diagram').addEventListener('click', () => {
            this.navigateDiagram(1);
        });

        document.getElementById('retry-button').addEventListener('click', () => {
            this.hideError();
            if (this.currentType) {
                this.showDiagramList(this.currentType);
            }
        });

        // Keyboard management
        document.addEventListener('keydown', (e) => {
            if (this.getCurrentPage() === 'viewer') {
                switch(e.key) {
                    case 'ArrowLeft':
                        e.preventDefault();
                        this.navigateDiagram(-1);
                        break;
                    case 'ArrowRight':
                        e.preventDefault();
                        this.navigateDiagram(1);
                        break;
                    case 'Escape':
                        e.preventDefault();
                        this.showPage('home');
                        break;
                }
            }
        });
    }

    /**
     * Show a specific page
     */
    showPage(pageId) {
        document.querySelectorAll('.page').forEach(page => {
            page.classList.remove('active');
        });
        document.getElementById(`${pageId}-page`).classList.add('active');
    }

    /**
     * Gets the current page
     */
    getCurrentPage() {
        const activePage = document.querySelector('.page.active');
        return activePage ? activePage.id.replace('-page', '') : null;
    }

    /**
     * Show the list of diagrams for a specific type
     */
    async showDiagramList(type) {
        if (!this.diagramTypes[type]) {
            this.showError('Invalid diagram type');
            return;
        }

        this.showLoading();

        try {
            await this.loadDiagramListByType(type);
            this.renderDiagramList(type);
            this.showPage('list');
        } catch (error) {
            console.error(`Error loading list for type: ${type}`);
            this.showError(`Error loading diagrams list for type: ${type}`);
        } finally {
            this.hideLoading();
        }
    }

    /**
     * Load the list of diagrams for a type
     */
    async loadDiagramListByType(type) {

        // Simulates asynchronous loading (DEBUG)
        // await new Promise(resolve => setTimeout(resolve, 300));

        this.currentType = type;
        this.diagrams = this.mockData[type] || [];
        this.diagrams.sort((a, b) => a.title.localeCompare(b.title));
    }

    /**
     * Render the list of diagrams
     */
    renderDiagramList(type) {
        const listTitle = document.getElementById('list-title');
        const diagramList = document.getElementById('diagram-list');
        
        listTitle.textContent = this.diagramTypes[type].title;
        diagramList.innerHTML = '';

        if (this.diagrams.length === 0) {
            diagramList.innerHTML = '<p style="text-align: center; color: var(--text-light); padding: 40px;">No diagram available</p>';
            return;
        }

        this.diagrams.forEach((diagram, index) => {
            const item = document.createElement('div');
            item.className = 'diagram-item';
            item.innerHTML = `<h3>${diagram.title}</h3>`;
            item.addEventListener('click', () => {
                this.showDiagram(index);
            });
            diagramList.appendChild(item);
        });
    }

    /**
     * Show a specific diagram
     */
    async showDiagram(index) {
        if (index < 0 || index >= this.diagrams.length) return;

        this.currentDiagramIndex = index;
        this.showLoading();

        try {
            await this.loadDiagram(this.diagrams[index]);
            this.updateNavigationButtons();
            this.showPage('viewer');
        } catch (error) {
            console.error('Error loading diagram:', error);
            this.showError('Error loading diagram');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * Upload a diagram and its associated map
     */
    async loadDiagram(diagram) {
        const folder = this.diagramTypes[this.currentType].folder;
        const imagePath = `ql-diagram/${folder}/${diagram.filename}`;
        const cmapxPath = `ql-diagram/${folder}/${diagram.filename.replace('.png', '.cmapx')}`;
        
        const imageElement = document.getElementById('diagram-image');
        
        await this.loadImage(imagePath, imageElement);
        
        this.removeExistingMaps();
        
        // Upload the map if it exists
        try {
            const mapContent = await this.loadImageMap(cmapxPath);
            if (mapContent) {
                this.applyImageMap(mapContent, imageElement);
            }
        } catch (error) {
            //console.log('No map available for this diagram.');
        }
    }

    /**
     * Upload an image
     */
    loadImage(src, imageElement) {
        return new Promise((resolve, reject) => {
            imageElement.onload = resolve;
            imageElement.onerror = reject;
            imageElement.src = src;
            imageElement.alt = `Diagram: ${this.diagrams[this.currentDiagramIndex].title}`;
        });
    }

    /**
     * Upload image map via AJAX
     */
    async loadImageMap(cmapxPath) {
        try {
            const response = await fetch(cmapxPath);
            if (!response.ok) throw new Error('Map not found');
            return await response.text();
        } catch (error) {
            return null;
        }
    }

    /**
     * Removes existing maps from the DOM
     */
    removeExistingMaps() {
        const existingMaps = document.querySelectorAll('map[id*="map"]');
        existingMaps.forEach(map => map.remove());
        
        const imageElement = document.getElementById('diagram-image');
        imageElement.removeAttribute('usemap');
    }

    /**
     * Handles the map coordinate shift caused by image resizing
     */
    setMapCoordsScaling() {
        imageMapResize();
        window.dispatchEvent(new Event('resize'));
    }

    /**
     * Apply the map to the image
     */
    applyImageMap(mapContent, imageElement) {
        const mapMatch = mapContent.match(/<map[^>\n]+>([\s\S\n]*?)<\/map>/i);

        if (!mapMatch) return;

        const mapElement = document.createElement('div');
        mapElement.innerHTML = mapContent;
        const map = mapElement.querySelector('map');
        
        if (map) {
            document.body.appendChild(map);
            
            const mapName = map.getAttribute('name') || map.getAttribute('id');
            if (mapName) {
                imageElement.setAttribute('usemap', `#${mapName}`);
            }

            const areas = map.querySelectorAll('area');
            areas.forEach(area => {
                const href = area.getAttribute('href');
                if (href && href.endsWith('.png')) {
                    area.addEventListener('click', (e) => {
                        e.preventDefault();
                        this.navigateToLinkedDiagram(href);
                    });
                }
            });

            this.setMapCoordsScaling();
        }
    }

    /**
     * Navigate to a linked diagram
     */
    async navigateToLinkedDiagram(filename) {
        let showFlag = false;
        let targetIndex = -1;
        let type = this.currentType;

        const targetDiagram = this.diagrams.find(d => d.filename === filename);
        // internal link
        if (targetDiagram) {
            targetIndex = this.diagrams.indexOf(targetDiagram);
            showFlag = true;
        }
        // external link
        else {
            console.info(`Diagram not found: ${filename}`);
            Object.keys(this.diagramTypes).forEach(key => {
                if (!showFlag && key != this.currentType) {
                    console.info(`Diagram not found in ${key}: ${filename}`);
                    let target = this.mockData[key].find(d => d.filename === filename);
                    console.info(target);
                    if (target) {
                        targetIndex = this.mockData[key].indexOf(target);
                        type = key;
                        showFlag = true;
                    }
                }
            });
        }

        if (showFlag) {
            try {
                await this.loadDiagramListByType(type);
                await this.showDiagram(targetIndex);
            } catch (error) {
                console.error(`Error loading list for type: ${type}`);
                this.showError(`Error loading diagrams list for type: ${type}`);
            }
        }
    }

    /**
     * Navigation between diagrams
     */
    navigateDiagram(direction) {
        const newIndex = this.currentDiagramIndex + direction;
        if (newIndex >= 0 && newIndex < this.diagrams.length) {
            this.showDiagram(newIndex);
        }
    }

    /**
     * Update the status of navigation buttons
     */
    updateNavigationButtons() {
        const prevBtn = document.getElementById('prev-diagram');
        const nextBtn = document.getElementById('next-diagram');
        
        prevBtn.disabled = this.currentDiagramIndex === 0;
        nextBtn.disabled = this.currentDiagramIndex === this.diagrams.length - 1;
    }

    /**
     * Mostra l'indicatore di caricamento
     */
    showLoading() {
        document.getElementById('loading').classList.remove('hidden');
    }

    /**
     * Hides the loading indicator
     */
    hideLoading() {
        document.getElementById('loading').classList.add('hidden');
    }

    /**
     * Show an error message
     */
    showError(message) {
        const errorElement = document.getElementById('error-message');
        errorElement.querySelector('p').textContent = message;
        errorElement.classList.remove('hidden');
    }

    /**
     * Hides the error message
     */
    hideError() {
        document.getElementById('error-message').classList.add('hidden');
    }
}


document.addEventListener('DOMContentLoaded', () => {
    new PlantUMLDocs();
});