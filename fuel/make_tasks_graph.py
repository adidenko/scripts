#!/usr/bin/env python

import yaml
import pygraphviz as pgv
import argparse
import glob
import os

class MakeGraph:
    def __init__(self):
        self._data = {}
        self._workbook = []
        self._graph = None
        self.new_graph()

    options = {
        'debug': False,
        'prog': 'dot',
        'role_node': {
            'shape': 'rectangle',
            'fillcolor': 'deepskyblue',
        },
        'task_node': {
            'shape': 'ellipse',
            'fillcolor': 'yellow',
        },
        'default_edge': {
        },
        'edge_task_to_role': {
        },
        'edge_role_to_role': {
        },
        'edge_to_stage': {
            'style': 'invis',
            'dir': 'none',
        },
        'global_graph': {
            'overlap': 'false',
            'splines': 'polyline',
            'pack': 'true',
            'sep': '1,1',
            'esep': '0.8,0.8',
        },
        'global_node': {
            'style': 'filled',
        },
        'global_edge': {
            'style': 'solid',
            'arrowhead': 'vee',
        }
    }

    def debug_print(self, msg):
        if self.options.get('debug', False):
            print msg

    def new_graph(self):
        self._graph = pgv.AGraph(strict=False, directed=True)

    # graph functions

    def graph_node(self, id, options=None):
        if not options:
            options = {}
        for option, value in self.node_options(id).iteritems():
            if option not in options:
                options[option] = value
        self.debug_print("Node: %s (%s)" % (id, repr(options)))
        if not self.graph.has_node(id):
            self.graph.add_node(id)
        node = self.graph.get_node(id)
        for attr_name, attr_value in options.iteritems():
            node.attr[attr_name] = attr_value
        return node

    def graph_edge(self, from_node, to_node, options=None):
        if not options:
            options = {}
        for option, value in self.edge_options(from_node, to_node).iteritems():
            if option not in options:
                options[option] = value
        self.debug_print("Edge: %s -> %s (%s)" % (from_node, to_node, repr(options)))
        if not self.graph.has_edge(from_node, to_node):
            self.graph.add_edge(from_node, to_node)
        edge = self.graph.get_edge(from_node, to_node)
        for attr_name in options:
            edge.attr[attr_name] = options[attr_name]
        return edge

    def edge_options(self, from_node, to_node):
        from_type = self.data[from_node]['type']
        to_type = self.data[to_node]['type']
        if to_type == 'stage':
            return self.options['edge_to_stage']
        elif to_type == 'role':
            if from_type == 'role':
                return self.options['edge_role_to_role']
            else:
                return self.options['edge_task_to_role']
        else:
            return self.options['default_edge']

    def node_options(self, node):
        node_type = self.node_type(node)
        if node_type == 'role':
            return self.options['role_node']
        else:
            return self.options['task_node']

    # data functions

    # convert array data to hash data
    def convert_data(self, group):
        # form the initial data structure
        for node in self.workbook:
            if not type(node) is dict:
                continue
            if not node.get('type', None) and node.get('id', None):
                continue
            id = node.get('id', None)
            node_type = node.get('type', None)
            requires = node.get('requires', [])
            required_for = node.get('required_for', [])
            role = node.get('role', [])
            groups = node.get('groups', [])
            self._data[id] = {
                'id': id,
                'requires': requires,
                'required_for': required_for,
                'type': node_type,
                'groups': groups,
            }

        # clean the data dictionary
        cleaned_data = {}
        for node in self.data.iterkeys():
            # filter out stage nodes
            if self.node_type(node) == 'stage' or self.node_type(node) == 'group':
                continue
            if group not in self.data[node].get('groups', []):
                continue
            # node structure
            id = self.data[node].get('id', None)
            node_type = self.data[node].get('type', None)
            cleaned_data[node] = {
                'id': id,
                'type': node_type,
                'links': [],
            }

        # convert links
        for node in cleaned_data:
            required_for = self.data[node]['required_for']
            requires = self.data[node]['requires']

            # cross-join requires and requires_for
            for reqf in required_for:
                if reqf in cleaned_data:
                    cleaned_data[node]['links'].append(reqf)
            for req in requires:
                if req in cleaned_data:
                    cleaned_data[req]['links'].append(node)

        # clean links
        for node in cleaned_data:
            links = cleaned_data[node]['links']
            filtered_links = []

            # find if there are some links to tasks
            has_task_links = False
            for link in links:
                if self.node_type(link) != 'role':
                    has_task_links = True

            # keep links to roles only if there are no links to tasks
            for link in links:
                if has_task_links and self.node_type(link) == 'role':
                    continue
                filtered_links.append(link)

            cleaned_data[node]['links'] = filtered_links

        # save cleaned data to the object
        self._data = cleaned_data
        return self._data

    # build graph structure using data
    def build_graph(self, group):
        self.convert_data(group)
        for id, node in self.data.iteritems():
            self.graph_node(id)
            for link in node['links']:
                self.graph_edge(id, link)

    def node_exists(self, node):
        return node in self.data

    def node_type(self, node):
        if not self.node_exists(node):
            return None
        return self.data[node]['type']

    # IO functions

    def load_data(self, workbook):
        self._workbook = workbook

    def load_yaml(self, yaml_workbook):
        self._workbook = yaml.load(yaml_workbook)

    def write_dot(self, dot_file):
        self.graph.write(dot_file)

    def write_image(self, img_file):
        for attr_name in self.options['global_graph']:
            self.graph.graph_attr[attr_name] = self.options['global_graph'][attr_name]
        for attr_name in self.options['global_node']:
            self.graph.node_attr[attr_name] = self.options['global_node'][attr_name]
        for attr_name in self.options['global_edge']:
            self.graph.edge_attr[attr_name] = self.options['global_edge'][attr_name]
        self.graph.layout(prog=self.options['prog'])
        self.graph.draw(img_file)

    @property
    def workbook(self):
        return self._workbook

    @property
    def data(self):
        return self._data

    @property
    def graph(self):
        return self._graph

def make_graph(tasks_yaml = "./osnailyfacter/modular", out_name = "tasks_graph", write_dot = False, group = 'primary-controller', debug = False):
    DEPLOYMENT_CURRENT = ""
    print("Found the following tasks:")
    for root, dirs, files in os.walk(tasks_yaml):
        for file in files:
            if file.endswith("tasks.yaml"):
                 print("\t%s" % os.path.join(root, file))
                 with open (os.path.join(root, file), "r") as myfile:
                     DEPLOYMENT_CURRENT += myfile.read()

    print("\nBuilding graph for tasks group (node role): %s\n" % group)
    mg = MakeGraph()
    mg.options['debug'] = debug
    mg.load_yaml(DEPLOYMENT_CURRENT)
    mg.build_graph(group)
    if write_dot:
        print("Saving dot file to: %s.dot" % out_name)
        mg.write_dot('%s.dot' % out_name)
    print("Saving image to: %s.png\n" % out_name)
    mg.write_image('%s.png' % out_name)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create Fuel tasks graph files.')
    parser.add_argument("tasks_directory", type=str, help="Directory with Fuel tasks.yaml files that contain tasks description")
    parser.add_argument("-wd", "--write-dot", help="Write .dot graph file", action="store_true")
    parser.add_argument("-d", "--debug", help="Print debug info", action="store_true")
    parser.add_argument("-of", "--out-name", help="Output file name to be used (without .png)", default='tasks_graph')
    parser.add_argument("-g", "--group", help="Tasks group name to build graph for. For example 'compute'", default='primary-controller')
    args = parser.parse_args()

    make_graph(args.tasks_directory, args.out_name, args.write_dot, args.group, args.debug)
