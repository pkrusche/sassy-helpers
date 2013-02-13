# -*- encoding: utf-8 -*-
require "modelling/sbml"
require "modelling/sassy"
module Modelling
	# Model Class
	class Model
		include Modelling::SBMLModel
		include Modelling::SassyModel

		# The name of the model
		attr_accessor :name

		# an array of reactions
		attr_accessor :reactions

		# a hash of parameters
		attr_accessor :parameters

		# a hash of species
		attr_accessor :species

		# an array of rules
		attr_accessor :rules

		# notes about the model
		attr_accessor :notes

		# extra comment for sassy
		attr_accessor :sassy_extra
		
		def initialize
			@reactions = []
			@rules = []
			@parameters = {}
			@species = {}
			@name = "Model"
			@parser = Modelling::SassyParser.new
			@sassy_extra = ""
			@notes = ""
		end

		# validate a model, i.e. make sure we all species and parameters
		def validate
			syms = {}
			idents = []
			@species.each {|k, v| syms[k] = v}
			@parameters.each do |k, v| 
				raise "Parameter and species share id: #{k}" if syms[k]
				syms[k] = v
			end
			syms.each do |k, v|
				raise "Symbol #{v.to_s} mapped to wrong id: #{k}" if v.name != k
			end
			@rules.each do |rule|
				if !syms.key?(rule.output.name)
					raise "rule #{rule.to_s} has undefined output: #{rule.output.name}"
				end
				rule.equation.all_idents.each do |id|
					idents = idents | [id]
					if !syms.key?(id)
						raise "rule #{rule.to_s} has undefined input: #{id}"
					# else
					# 	puts "#{id} used in #{rule.to_s}\n"
					end
				end
			end
			@reactions.each do |reaction|
				reaction.in do |input|
					if !@species.key?(input.name)
						raise "reaction #{reaction.to_s} has undefined input: #{input.name}"
					end
				end
				reaction.out do |output|
					if !@species.key?(output.name)
						raise "reaction #{reaction.to_s} has undefined output: #{output.name}"
					end
				end
				reaction.all_idents.each do |id|
					idents = idents | [id]
					if !syms.key?(id)
						raise "rule #{rule.to_s} has undefined input: #{id}"
					end
				end

			end

			unused = idents.reject { |e| syms.key?(e)  }
			unused = unused | (syms.keys.reject { |e| idents.index(e) })
			# dawn dusk and force are in every model (at least after sassy opens it)
			unused = unused.reject { |e| e == 'dawn' || e == 'dusk' || e == 'force' }
			if unused.length > 0
				puts "[W] Model has unused symbols: #{unused}\n"
			end
		end

		# Turn a parameter into a species
		# Returns: the Species object of the newly generated species
		def parameter_to_species(pname)
			raise "Unknown parameter #{pname}" if not @parameters.key?(pname)
			matlab_number = @species.values.inject (1) { |mem, var| mem < var.matlab_no ? var.matlab_no + 1 : mem }
			raise "Species #{pname} already exists, cannot replace." if @species.key?(pname)

			p = @parameters.delete pname
			spec = Species.new(pname, p.value, matlab_number)
			@species[pname] = spec

			self.validate
			spec
		end

		# get a symbol (species or parameter) object
		def get_symbol(sym)
			if @parameters.key?(sym)
				return @parameters[sym]
			elsif @spec
				return @species[sym]
			else
				raise "Symbol #{sym} not found in model"
			end
		end

		# Test if model has a certain symbol
		def has_symbol?(sym)
			@parameters.key?(sym) or @species.key?(sym)
		end

		# Replace a symbol in all equations
		# Removes the object for sym and returns it
		def replace_symbol(sym, new_sym)
			syo = get_symbol(sym)
			syn = get_symbol(new_sym)

			@rules.each do |r|
				r.equation.replace_ident(sym, new_sym)
			end

			@reactions.each do |r|
				r.equation.replace_ident(sym, new_sym)
			end

			if @parameters[sym]
				@parameters.delete(sym)
			else
				@species.delete(sym)
			end

			self.validate

			syo
		end

	end
end